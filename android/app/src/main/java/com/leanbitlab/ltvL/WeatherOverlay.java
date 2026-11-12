package com.leanbitlab.ltvL;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Tarjeta pequeña del clima que aparece encima de cualquier app (TizenTube,
 * documentales, etc.) durante unos segundos cada vez que llega un dato nuevo.
 * No recibe foco ni toques, así que el mando sigue controlando la app de abajo.
 */
final class WeatherOverlay {
    private static final long SHOW_MILLIS = 10_000L;
    private static final Handler MAIN = new Handler(Looper.getMainLooper());
    private static LinearLayout sView;
    private static final Runnable HIDE = WeatherOverlay::hide;

    private WeatherOverlay() {
    }

    /** Muestra el clima a partir del JSON recibido. Ignora el dato si no hay permiso. */
    static void showFromJson(Context context, String weatherJson) {
        if (weatherJson == null || weatherJson.isEmpty()) return;
        if (!canDraw(context)) return;
        final String[] lines = describe(weatherJson);
        if (lines == null) return;
        MAIN.post(() -> show(context.getApplicationContext(), lines[0], lines[1]));
    }

    private static boolean canDraw(Context context) {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(context);
    }

    /** Devuelve {titulo, detalle} o null si el JSON no trae lo necesario. */
    static String[] describe(String weatherJson) {
        try {
            JSONObject json = new JSONObject(weatherJson);
            String location = json.optString("location", "");
            Integer temp = parseTemperature(json.opt("currentTemp"));
            String condition = json.optString("currentCondition", "");

            String title = location.isEmpty() ? "Clima" : location;
            if (temp != null) title += " · " + temp + "°C";

            StringBuilder detail = new StringBuilder();
            if (!condition.isEmpty()) detail.append(condition);
            JSONArray forecasts = json.optJSONArray("forecasts");
            if (forecasts != null && forecasts.length() > 0) {
                Integer rain = parseInt(forecasts.getJSONObject(0).opt("precipProbability"));
                if (rain != null) {
                    if (detail.length() > 0) detail.append(" · ");
                    detail.append("Lluvia hoy ").append(rain).append("%");
                }
            }
            if (title.equals("Clima") && detail.length() == 0) return null;
            return new String[] {title, detail.toString()};
        } catch (Exception e) {
            return null;
        }
    }

    // Mismas reglas que lib/models/weather_data.dart: valores mayores de 100 son Kelvin.
    private static Integer parseTemperature(Object value) {
        Double n = toNumber(value);
        if (n == null) return null;
        if (n > 100) return (int) Math.round(n - 273.15);
        return (int) Math.round(n);
    }

    private static Integer parseInt(Object value) {
        Double n = toNumber(value);
        return n == null ? null : (int) Math.round(n);
    }

    private static Double toNumber(Object value) {
        if (value instanceof Number) return ((Number) value).doubleValue();
        if (value instanceof String) {
            try {
                return Double.parseDouble(((String) value).trim());
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    private static void show(Context context, String title, String detail) {
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        if (windowManager == null) return;
        hide();

        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(dp(context, 18), dp(context, 12), dp(context, 18), dp(context, 12));
        GradientDrawable background = new GradientDrawable();
        background.setColor(Color.argb(190, 10, 12, 20));
        background.setCornerRadius(dp(context, 14));
        card.setBackground(background);

        TextView titleView = new TextView(context);
        titleView.setText(title);
        titleView.setTextColor(Color.WHITE);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 22);
        titleView.setSingleLine(true);
        card.addView(titleView);

        if (!detail.isEmpty()) {
            TextView detailView = new TextView(context);
            detailView.setText(detail);
            detailView.setTextColor(Color.argb(230, 255, 255, 255));
            detailView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
            detailView.setSingleLine(true);
            card.addView(detailView);
        }

        int type = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                : WindowManager.LayoutParams.TYPE_PHONE;
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                type,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        | WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                        | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                android.graphics.PixelFormat.TRANSLUCENT);
        params.gravity = Gravity.TOP | Gravity.END;
        params.x = dp(context, 48);
        params.y = dp(context, 48);

        try {
            windowManager.addView(card, params);
            sView = card;
            MAIN.postDelayed(HIDE, SHOW_MILLIS);
        } catch (RuntimeException ignored) {
            // Sin permiso o ventana rechazada: el launcher sigue funcionando.
            sView = null;
        }
    }

    private static void hide() {
        MAIN.removeCallbacks(HIDE);
        if (sView == null) return;
        try {
            WindowManager wm = (WindowManager) sView.getContext().getSystemService(Context.WINDOW_SERVICE);
            if (wm != null) wm.removeViewImmediate(sView);
        } catch (RuntimeException ignored) {
        }
        sView = null;
    }

    private static int dp(Context context, int value) {
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, context.getResources().getDisplayMetrics()));
    }
}

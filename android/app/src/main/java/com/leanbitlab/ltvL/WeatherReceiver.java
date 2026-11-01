package com.leanbitlab.ltvL;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.nio.charset.StandardCharsets;

public class WeatherReceiver extends BroadcastReceiver {
    public static final String ACTION_GENERIC_WEATHER = "nodomain.freeyourgadget.gadgetbridge.ACTION_GENERIC_WEATHER";
    public static final String ACTION_BREEZY_UPDATE_NOTIFIER = "org.breezyweather.ACTION_UPDATE_NOTIFIER";
    public static final String ACTION_BREEZY_UPDATE_NOTIFIER_DEBUG = "org.breezyweather.debug.ACTION_UPDATE_NOTIFIER";
    public static final String PREFS_NAME = "lwidget_breezy_weather_data";
    public static final String KEY_WEATHER_JSON = "weather_json";
    private static final String EXTRA_WEATHER_JSON = "WeatherJson";
    private static final String EXTRA_WEATHER_JSON_LOWERCASE = "weatherJson";
    static final int MAX_WEATHER_JSON_BYTES = 256 * 1024;

    public interface WeatherListener {
        void onWeatherUpdated(String weatherJson);
    }

    private static WeatherListener sListener;

    public static void setListener(WeatherListener listener) {
        sListener = listener;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            handleReceive(context, intent);
        } catch (RuntimeException ignored) {
            // Malformed extras or storage failures must not terminate the launcher.
        }
    }

    private void handleReceive(Context context, Intent intent) {
        if (intent == null) return;
        String action = intent.getAction();
        if (!ACTION_GENERIC_WEATHER.equals(action)
                && !ACTION_BREEZY_UPDATE_NOTIFIER.equals(action)
                && !ACTION_BREEZY_UPDATE_NOTIFIER_DEBUG.equals(action)) {
            return;
        }

        String weatherJson = intent.getStringExtra(EXTRA_WEATHER_JSON);
        if (weatherJson == null || weatherJson.isEmpty()) {
            weatherJson = intent.getStringExtra(EXTRA_WEATHER_JSON_LOWERCASE);
        }

        if (weatherJson != null && !weatherJson.isEmpty()) {
            if (!isValidWeatherJson(weatherJson)) return;
            SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            prefs.edit().putString(KEY_WEATHER_JSON, weatherJson).apply();
        } else {
            SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            weatherJson = prefs.getString(KEY_WEATHER_JSON, null);
        }
        if (weatherJson != null && sListener != null) {
            try {
                sListener.onWeatherUpdated(weatherJson);
            } catch (RuntimeException ignored) {
                // A receiver must not crash the launcher because of a listener.
            }
        }
    }

    static boolean isValidWeatherJson(String weatherJson) {
        if (weatherJson == null || weatherJson.trim().isEmpty()
                || weatherJson.length() > MAX_WEATHER_JSON_BYTES) {
            return false;
        }
        try {
            if (weatherJson.getBytes(StandardCharsets.UTF_8).length > MAX_WEATHER_JSON_BYTES) {
                return false;
            }
            JSONObject weather = new JSONObject(weatherJson);
            return validateWeatherFields(weather)
                    && validateArray(weather, "forecasts")
                    && validateArray(weather, "hourly")
                    && validateObject(weather, "airQuality");
        } catch (JSONException | RuntimeException ignored) {
            return false;
        }
    }

    private static boolean validateWeatherFields(JSONObject weather) throws JSONException {
        return stringOrNull(weather, "location")
                && stringOrNull(weather, "currentCondition")
                && numbersOrNull(weather,
                "timestamp", "currentTemp", "currentConditionCode", "currentHumidity",
                "todayMaxTemp", "todayMinTemp", "windSpeed", "windDirection", "uvIndex",
                "precipProbability", "dewPoint", "pressure", "cloudCover", "visibility",
                "sunRise", "sunSet", "moonRise", "moonSet", "moonPhase", "latitude", "longitude",
                "feelsLikeTemp", "isCurrentLocation");
    }

    private static boolean validateArray(JSONObject parent, String name) throws JSONException {
        if (!parent.has(name) || parent.isNull(name)) return true;
        Object value = parent.get(name);
        if (!(value instanceof JSONArray)) return false;
        JSONArray array = (JSONArray) value;
        for (int i = 0; i < array.length(); i++) {
            Object item = array.get(i);
            if (!(item instanceof JSONObject)) return false;
            JSONObject object = (JSONObject) item;
            if (!numbersOrNull(object,
                    "minTemp", "maxTemp", "conditionCode", "humidity", "windSpeed", "windDirection",
                    "uvIndex", "precipProbability", "sunRise", "sunSet", "moonRise", "moonSet",
                    "moonPhase", "pressure", "cloudCover", "timestamp", "temp", "dewPoint")) {
                return false;
            }
            if (!validateObject(object, "airQuality")) return false;
        }
        return true;
    }

    private static boolean validateObject(JSONObject parent, String name) throws JSONException {
        if (!parent.has(name) || parent.isNull(name)) return true;
        Object value = parent.get(name);
        return value instanceof JSONObject
                && numbersOrNull((JSONObject) value,
                "aqi", "co", "no2", "o3", "pm10", "pm25", "so2", "coAqi", "no2Aqi",
                "o3Aqi", "pm10Aqi", "pm25Aqi", "so2Aqi");
    }

    private static boolean stringOrNull(JSONObject object, String name) throws JSONException {
        return !object.has(name) || object.isNull(name) || object.get(name) instanceof String;
    }

    private static boolean numbersOrNull(JSONObject object, String... names) throws JSONException {
        for (String name : names) {
            if (object.has(name) && !object.isNull(name) && !(object.get(name) instanceof Number)) {
                return false;
            }
        }
        return true;
    }

}

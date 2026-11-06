package com.leanbitlab.ltvL;

import android.app.AppOpsManager;
import android.app.usage.NetworkStats;
import android.app.usage.NetworkStatsManager;
import android.content.Context;
import android.net.ConnectivityManager;
import android.os.Build;
import androidx.annotation.RequiresApi;
import androidx.annotation.DoNotInline;

/** Loaded only after the API 23 guard in MainActivity. */
@RequiresApi(Build.VERSION_CODES.M)
final class NetworkUsageApi23 {
    private final Context context;

    NetworkUsageApi23(Context context) {
        this.context = context;
    }

    @DoNotInline
    long getDailyDataUsage() {
        if (!checkUsageStatsPermission()) {
            return -1;
        }

        NetworkStatsManager networkStatsManager = (NetworkStatsManager) context.getSystemService(Context.NETWORK_STATS_SERVICE);
        if (networkStatsManager == null)
            return 0;


        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        long endTime = System.currentTimeMillis();

        long totalBytes = 0;
        try {
            NetworkStats.Bucket wifiBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_WIFI,
                    null,
                    startTime,
                    endTime);
            if (wifiBucket != null) {
                totalBytes += wifiBucket.getRxBytes() + wifiBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            NetworkStats.Bucket mobileBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_MOBILE,
                    null,
                    startTime,
                    endTime);
            if (mobileBucket != null) {
                totalBytes += mobileBucket.getRxBytes() + mobileBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            NetworkStats.Bucket ethernetBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_ETHERNET,
                    null,
                    startTime,
                    endTime);
            if (ethernetBucket != null) {
                totalBytes += ethernetBucket.getRxBytes() + ethernetBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return totalBytes;
    }

    @DoNotInline
    long getWeeklyDataUsage() {
        if (!checkUsageStatsPermission()) {
            return -1;
        }

        NetworkStatsManager networkStatsManager = (NetworkStatsManager) context.getSystemService(Context.NETWORK_STATS_SERVICE);
        if (networkStatsManager == null)
            return 0;


        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_WEEK, calendar.getFirstDayOfWeek());
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        long endTime = System.currentTimeMillis();

        long totalBytes = 0;
        try {
            NetworkStats.Bucket wifiBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_WIFI,
                    null,
                    startTime,
                    endTime);
            if (wifiBucket != null) {
                totalBytes += wifiBucket.getRxBytes() + wifiBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            NetworkStats.Bucket mobileBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_MOBILE,
                    null,
                    startTime,
                    endTime);
            if (mobileBucket != null) {
                totalBytes += mobileBucket.getRxBytes() + mobileBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            NetworkStats.Bucket ethernetBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_ETHERNET,
                    null,
                    startTime,
                    endTime);
            if (ethernetBucket != null) {
                totalBytes += ethernetBucket.getRxBytes() + ethernetBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return totalBytes;
    }

    @DoNotInline
    long getMonthlyDataUsage() {
        if (!checkUsageStatsPermission()) {
            return -1;
        }

        NetworkStatsManager networkStatsManager = (NetworkStatsManager) context.getSystemService(Context.NETWORK_STATS_SERVICE);
        if (networkStatsManager == null)
            return 0;


        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_MONTH, 1);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        long endTime = System.currentTimeMillis();

        long totalBytes = 0;
        try {
            NetworkStats.Bucket wifiBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_WIFI,
                    null,
                    startTime,
                    endTime);
            if (wifiBucket != null) {
                totalBytes += wifiBucket.getRxBytes() + wifiBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            NetworkStats.Bucket mobileBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_MOBILE,
                    null,
                    startTime,
                    endTime);
            if (mobileBucket != null) {
                totalBytes += mobileBucket.getRxBytes() + mobileBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            NetworkStats.Bucket ethernetBucket = networkStatsManager.querySummaryForDevice(
                    ConnectivityManager.TYPE_ETHERNET,
                    null,
                    startTime,
                    endTime);
            if (ethernetBucket != null) {
                totalBytes += ethernetBucket.getRxBytes() + ethernetBucket.getTxBytes();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return totalBytes;
    }

    @DoNotInline
    boolean checkUsageStatsPermission() {
        AppOpsManager appOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
        if (appOps == null) return false;
        int mode;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            mode = appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(), context.getPackageName());
        } else {
            mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(), context.getPackageName());
        }

        if (mode == AppOpsManager.MODE_ALLOWED) {
            return true;
        }

        if (mode == AppOpsManager.MODE_DEFAULT) {
            try {
                NetworkStatsManager networkStatsManager = (NetworkStatsManager) context.getSystemService(Context.NETWORK_STATS_SERVICE);
                if (networkStatsManager != null) {
                    long now = System.currentTimeMillis();
                    networkStatsManager.querySummaryForDevice(ConnectivityManager.TYPE_WIFI, null, now - 1, now);
                    return true;
                }
            } catch (SecurityException e) {
                return false;
            } catch (Exception e) {
                return true;
            }
        }

        return false;
    }

}

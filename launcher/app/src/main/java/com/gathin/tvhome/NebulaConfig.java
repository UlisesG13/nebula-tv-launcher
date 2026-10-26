package com.gathin.tvhome;

import android.content.Context;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;

/**
 * Nebula extras read straight from the same overlay file Config uses
 * ({@code /sdcard/Android/data/<pkg>/files/config.json}), kept out of Config's big constructor:
 *  - {@code schedule}: the hours (0-23) that start morning, day, afternoon and night. Drives both the
 *    greeting (días/tardes/noches) and which wallpaper group shows.
 *  - {@code clock_format}: "system" (default), "12h" or "24h".
 * Everything is optional and falls back to sensible defaults, so a missing file changes nothing.
 */
final class NebulaConfig {

    static final int[] DEFAULT_SCHEDULE = {5, 8, 13, 20};   // morning, day, afternoon, night

    private NebulaConfig() {
    }

    static int[] schedule(Context ctx) {
        JSONObject root = read(ctx);
        if (root == null) return DEFAULT_SCHEDULE.clone();
        JSONObject s = root.optJSONObject("schedule");
        if (s == null) return DEFAULT_SCHEDULE.clone();
        int[] out = {
                clampHour(s.optInt("morning", DEFAULT_SCHEDULE[0]), DEFAULT_SCHEDULE[0]),
                clampHour(s.optInt("day", DEFAULT_SCHEDULE[1]), DEFAULT_SCHEDULE[1]),
                clampHour(s.optInt("afternoon", DEFAULT_SCHEDULE[2]), DEFAULT_SCHEDULE[2]),
                clampHour(s.optInt("night", DEFAULT_SCHEDULE[3]), DEFAULT_SCHEDULE[3]),
        };
        // Only trust a strictly increasing morning < day < afternoon < night; otherwise the defaults.
        if (out[0] < out[1] && out[1] < out[2] && out[2] < out[3]) return out;
        return DEFAULT_SCHEDULE.clone();
    }

    static String clockFormat(Context ctx) {
        JSONObject root = read(ctx);
        String v = root == null ? "system" : root.optString("clock_format", "system");
        return ("12h".equals(v) || "24h".equals(v)) ? v : "system";
    }

    private static int clampHour(int h, int fallback) {
        return (h >= 0 && h <= 23) ? h : fallback;
    }

    private static JSONObject read(Context ctx) {
        try {
            File dir = ctx.getExternalFilesDir(null);
            if (dir == null) return null;
            File f = new File(dir, Config.FILE_NAME);
            if (!f.exists()) return null;
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            try (FileInputStream in = new FileInputStream(f)) {
                byte[] buf = new byte[4096];
                int n;
                while ((n = in.read(buf)) > 0) out.write(buf, 0, n);
            }
            return new JSONObject(out.toString("UTF-8"));
        } catch (Exception e) {
            return null;
        }
    }
}

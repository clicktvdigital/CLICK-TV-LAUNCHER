package com.leanbitlab.ltvL;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class WeatherReceiverTest {
    @Test
    public void acceptsGadgetbridgeWeatherJsonWithOptionalFields() {
        String json = "{\"location\":\"Quito\",\"currentTemp\":300,"
                + "\"currentConditionCode\":500,\"forecasts\":["
                + "{\"conditionCode\":500,\"precipProbability\":80}],"
                + "\"hourly\":[],\"airQuality\":null}";

        assertTrue(WeatherReceiver.isValidWeatherJson(json));
    }

    @Test
    public void rejectsMalformedJson() {
        assertFalse(WeatherReceiver.isValidWeatherJson("{\"location\":\"Quito\""));
    }

    @Test
    public void rejectsEmptyJson() {
        assertFalse(WeatherReceiver.isValidWeatherJson(""));
        assertFalse(WeatherReceiver.isValidWeatherJson("   "));
    }

    @Test
    public void rejectsUnexpectedStructureOrKnownFieldType() {
        assertFalse(WeatherReceiver.isValidWeatherJson("[]"));
        assertFalse(WeatherReceiver.isValidWeatherJson("{\"currentTemp\":\"300\"}"));
    }

    @Test
    public void acceptsAdditionalCompatibleFields() {
        String json = "{\"location\":\"Quito\",\"currentTemp\":300,"
                + "\"futureProviderField\":{\"revision\":2},"
                + "\"forecasts\":[{\"conditionCode\":500,"
                + "\"futureDailyField\":true}],"
                + "\"airQuality\":{\"futureAqiField\":\"index-v2\"}}";

        assertTrue(WeatherReceiver.isValidWeatherJson(json));
    }

    @Test
    public void rejectsPayloadOverLimit() {
        StringBuilder json = new StringBuilder("{\"location\":\"");
        while (json.length() <= WeatherReceiver.MAX_WEATHER_JSON_BYTES) json.append('x');
        json.append("\"}");

        assertFalse(WeatherReceiver.isValidWeatherJson(json.toString()));
    }
}

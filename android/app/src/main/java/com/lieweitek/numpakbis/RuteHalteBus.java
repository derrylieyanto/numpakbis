package com.lieweitek.numpakbis;

public class RuteHalteBus implements Comparable<RuteHalteBus>{
    private String name;
    private String key;
    private String longitude;
    private String latitude;

    public RuteHalteBus(String name, String key, String latitude, String longitude) {
        this.name = name;
        this.key = key;
        this.longitude = longitude;
        this.latitude = latitude;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    @Override
    public int compareTo(RuteHalteBus o) {
        if (getKey() == null || o.getKey() == null) {
            return 0;
        }
        return getKey().compareTo(o.getKey());
    }

    @Override
    public String toString() {
        return "RuteHalteBus{" +
                "name='" + name + '\'' +
                ", key='" + key + '\'' +
                ", longitude='" + longitude + '\'' +
                ", latitude='" + latitude + '\'' +
                '}';
    }
}

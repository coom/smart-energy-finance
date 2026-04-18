🇬🇧 **English** | [🇫🇷 Français](./README_FR.md)

---

> 🔓 **Forked by coom — premium features are now free.**
> All dashboards and analytics are unlocked out of the box. No key, no purchase.

---

## 📊 Overview

<img src="https://raw.githubusercontent.com/coom/smart-energy-finance/main/smart-energy-finance/docs/images/compteur.png" width="900"/>

Smart Energy Finance is an advanced Home Assistant add-on designed to analyze the financial side of your energy system.

It helps you understand:

* real electricity cost
* solar production value
* battery profitability
* grid dependency
* self-sufficiency level
* savings over time

The add-on automatically creates Home Assistant entities and a ready-to-use dashboard to display daily, monthly, and yearly energy financial analytics.

---

## ⚠️ Important recommendation

For the best results, it is **strongly recommended** to use:

* ✅ daily energy counters in **kWh**
* ❌ NOT raw power sensors in **W**

Why:

* more accurate calculations
* better long-term stability
* reliable daily / monthly / yearly history
* fewer errors and drift over time

Power sensors can work in some cases, but energy counters remain the best and most reliable solution.

---

## 🔌 Compatibility

This module is compatible with:

* inverters
* solar panels
* battery systems
* Home Assistant energy sensors
* custom entities from other add-ons or integrations

It is designed to remain flexible and can work with many different system types as long as the required Home Assistant entities are available.

---

## 💰 What Smart Energy Finance does

The add-on automatically calculates and creates entities for:

* daily savings
* monthly savings
* yearly savings
* solar production financial value
* battery discharge financial value
* real total cost including subscription
* estimated cost without solar
* import/export cost analysis
* self-sufficiency and grid dependency ratios

---

## ⚡ Energy Dashboard

<img src="https://raw.githubusercontent.com/coom/smart-energy-finance/main/smart-energy-finance/docs/images/energie.png" width="900"/>

The Energy dashboard includes:

* solar / battery / grid distribution
* real-time energy mix
* self-sufficiency analysis
* grid dependency overview
* energy cost context
* analytics cards

---

## 🔋 Battery Dashboard

<img src="https://raw.githubusercontent.com/coom/smart-energy-finance/main/smart-energy-finance/docs/images/batterie.png" width="900"/>

The Battery dashboard includes:

* battery charge / discharge analysis
* battery usage financial value
* monthly and yearly battery statistics
* donut charts
* detailed battery savings view

---

## 💶 Economy Dashboard

<img src="https://raw.githubusercontent.com/coom/smart-energy-finance/main/smart-energy-finance/docs/images/economie.png" width="900"/>

The Economy dashboard includes:

* daily financial distribution
* monthly savings view
* yearly savings view
* solar value analysis
* battery savings impact
* subscription cost effect
* donut charts and history view

---

## 📈 Included features

All features are included — no key or purchase required:

* advanced dashboards
* daily / monthly / yearly history
* battery financial analytics
* donut charts
* long-term statistics
* richer Home Assistant views
* insights for energy optimization

---

## ⚙️ Example configuration

mqtt_host: core-mosquitto
mqtt_port: 1883
mqtt_user: user
mqtt_password: password

currency: EUR
contract_type: tempo

monthly_subscription_price: 12.5

dashboard_language: en
dashboard_custom_cards_installed: true

---

## 📊 Main generated sensors

### Financial

* sensor.smart_energy_finance_day_savings_vs_no_solar
* sensor.smart_energy_finance_month_savings_vs_no_solar
* sensor.smart_energy_finance_year_savings_vs_no_solar

### Energy

* sensor.smart_energy_finance_day_solar_kwh
* sensor.smart_energy_finance_day_grid_import_kwh
* sensor.smart_energy_finance_day_grid_export_kwh
* sensor.smart_energy_finance_day_load_kwh

### Battery

* sensor.smart_energy_finance_battery_day_savings
* sensor.smart_energy_finance_battery_month_savings
* sensor.smart_energy_finance_battery_year_savings

### History

* sensor.smart_energy_finance_history_archive

  * daily
  * monthly
  * yearly

---

## 🚀 Automatic dashboard creation

The add-on automatically creates a dashboard inside Home Assistant.

This means:

* no manual Lovelace setup required
* automatic entity usage
* FR / EN dashboard support
* works with or without custom cards
* optimized visual presentation

---

## 🛠️ Technologies used

* Node-RED
* MQTT Discovery
* ApexCharts
* Home Assistant Supervisor API

---

## 🧑‍💻 Credits

Originally developed by Tapion69. This is an MIT fork maintained by [coom](https://github.com/coom) with all features unlocked.

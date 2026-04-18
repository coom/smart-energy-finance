## 📊 Présentation

<img src="https://raw.githubusercontent.com/jean-luc1203/smart-energy-finance/main/smart-energy-finance/docs/images/compteur.png" width="900"/>

Smart Energy Finance est un add-on Home Assistant avancé conçu pour analyser la partie financière de votre installation énergétique.

Il permet de comprendre facilement :

* le coût réel de votre électricité
* la valeur de votre production solaire
* la rentabilité de votre batterie
* la dépendance au réseau
* votre niveau d’autosuffisance
* les économies réalisées dans le temps

L’add-on crée automatiquement des entités Home Assistant ainsi qu’un dashboard prêt à l’emploi pour afficher vos analyses financières au jour, au mois et à l’année.

---

## ⚠️ Recommandation importante

Pour obtenir les meilleurs résultats, il est **fortement recommandé** d’utiliser :

* ✅ des compteurs d’énergie journaliers en **kWh**
* ❌ et non des capteurs de puissance bruts en **W**

Pourquoi :

* calculs beaucoup plus précis
* meilleure stabilité dans le temps
* historique journalier / mensuel / annuel fiable
* moins d’erreurs et moins de dérive

Les capteurs de puissance peuvent fonctionner dans certains cas, mais les compteurs d’énergie restent la solution la plus propre et la plus fiable.

---

## 🔌 Compatibilité

Ce module est compatible avec :

* les onduleurs
* les panneaux solaires
* les batteries
* les capteurs d’énergie Home Assistant
* les entités personnalisées venant d’autres add-ons ou intégrations

Il a été conçu pour rester flexible et fonctionner avec de nombreux types d’installations, à condition que les entités nécessaires soient disponibles dans Home Assistant.

---

## 💰 Ce que fait Smart Energy Finance

L’add-on calcule automatiquement et crée des entités pour :

* les économies du jour
* les économies du mois
* les économies de l’année
* la valeur financière de la production solaire
* la valeur financière de la décharge batterie
* le coût réel total avec abonnement inclus
* le coût estimé sans solaire
* l’analyse import / export réseau
* les ratios d’autosuffisance et de dépendance réseau

---

## ⚡ Dashboard Énergie

<img src="https://raw.githubusercontent.com/jean-luc1203/smart-energy-finance/main/smart-energy-finance/docs/images/energie.png" width="900"/>

Le dashboard Énergie comprend :

* la répartition solaire / batterie / réseau
* le mix énergétique en temps réel
* l’analyse de l’autosuffisance
* la vue de dépendance réseau
* le contexte tarifaire énergétique
* des cartes d’analyse

---

## 🔋 Dashboard Batterie

<img src="https://raw.githubusercontent.com/jean-luc1203/smart-energy-finance/main/smart-energy-finance/docs/images/batterie.png" width="900"/>

Le dashboard Batterie comprend :

* l’analyse charge / décharge batterie
* la valorisation financière de l’usage batterie
* les statistiques batterie mensuelles et annuelles
* des donuts
* une vue détaillée des économies batterie

---

## 💶 Dashboard Économie

<img src="https://raw.githubusercontent.com/jean-luc1203/smart-energy-finance/main/smart-energy-finance/docs/images/economie.png" width="900"/>

Le dashboard Économie comprend :

* la répartition financière journalière
* la vue des économies mensuelles
* la vue des économies annuelles
* l’analyse de la valeur solaire
* l’impact financier de la batterie
* l’effet du coût d’abonnement
* des donuts et une vue historique

---

## 📈 Fonctionnalités incluses

Toutes les fonctionnalités sont incluses — aucune clé ni achat requis :

* dashboards avancés
* historique jour / mois / année
* analyse financière de la batterie
* donuts
* statistiques longue durée
* vues Home Assistant enrichies
* insights pour optimiser votre énergie

---

## ⚙️ Exemple de configuration

mqtt_host: core-mosquitto
mqtt_port: 1883
mqtt_user: user
mqtt_password: password

currency: EUR
contract_type: tempo

monthly_subscription_price: 12.5

dashboard_language: fr
dashboard_custom_cards_installed: true

---

## 📊 Principaux capteurs générés

### Finance

* sensor.smart_energy_finance_day_savings_vs_no_solar
* sensor.smart_energy_finance_month_savings_vs_no_solar
* sensor.smart_energy_finance_year_savings_vs_no_solar

### Énergie

* sensor.smart_energy_finance_day_solar_kwh
* sensor.smart_energy_finance_day_grid_import_kwh
* sensor.smart_energy_finance_day_grid_export_kwh
* sensor.smart_energy_finance_day_load_kwh

### Batterie

* sensor.smart_energy_finance_battery_day_savings
* sensor.smart_energy_finance_battery_month_savings
* sensor.smart_energy_finance_battery_year_savings

### Historique

* sensor.smart_energy_finance_history_archive

  * daily
  * monthly
  * yearly

---

## 🚀 Création automatique du dashboard

L’add-on crée automatiquement un dashboard dans Home Assistant.

Cela signifie :

* aucune configuration Lovelace manuelle nécessaire
* utilisation automatique des entités
* support FR / EN
* fonctionnement avec ou sans cartes custom
* présentation visuelle optimisée

---

## 🛠️ Technologies utilisées

* Node-RED
* MQTT Discovery
* ApexCharts
* API Supervisor Home Assistant

---

## 🧑‍💻 Crédits

Développé à l’origine par Tapion69. Ceci est un fork MIT avec toutes les fonctionnalités activées.

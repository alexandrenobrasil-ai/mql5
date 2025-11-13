# CHESS-160 EA - Scanner de Stratégies Échecs

Expert Advisor MetaTrader 5 qui analyse les mouvements de prix sur 160 minutes et les mappe sur 64 stratégies d'échecs classiques.

## 📋 Description

CHESS-160 est un système innovant qui :
- Scanne les 160 dernières minutes de prix (bougies M1)
- Identifie les points HIGH et LOW
- Mappe ces points sur 64 stratégies d'échecs (échiquier 8×8)
- Analyse la cohérence entre stratégies
- Envoie des alertes Telegram selon des critères configurables
- Génère des logs CSV pour analyse historique

## 🗂️ Structure des fichiers

```
CHESS_160.mq5        - Expert Advisor principal
ChessEngine.mqh      - 64 stratégies d'échecs (a1-h8)
CSVLogger.mqh        - Système de logging CSV
TelegramChess.mqh    - Alertes Telegram
HistoryTracker.mqh   - Suivi historique des stratégies
```

## ⚙️ Installation

1. Copiez tous les fichiers dans votre dossier MetaTrader 5 :
   - `CHESS_160.mq5` → `MQL5/Experts/`
   - `*.mqh` → `MQL5/Include/`

2. Compilez le fichier `CHESS_160.mq5` dans MetaEditor

3. Attachez l'EA à un graphique (n'importe quelle période)

## 🔧 Configuration

### Telegram
- `TelegramToken` : Token de votre bot Telegram
- `TelegramChatID` : Votre Chat ID
- `EnableTelegramAlerts` : Activer/désactiver les alertes

⚠️ **Important** : Pour que Telegram fonctionne, ajoutez l'URL dans MetaTrader :
- Outils → Options → Expert Advisors
- Cochez "Autoriser WebRequest pour les URLs suivantes"
- Ajoutez : `https://api.telegram.org`

### Symboles
- `ChessSymbolsList` : Liste manuelle (ex: "EURUSD,GBPUSD,XAUUSD")
- `ScanAllMarketWatch` : Scanner tous les symboles du Market Watch

### Scanning
- `EnableAutoScan` : Scan automatique périodique
- `ScanIntervalMinutes` : Intervalle entre scans (défaut: 60 min)
- `ScanOnInit` : Lancer un scan au démarrage

### Filtres d'alerte
- `MinRiskThreshold` : Risque minimum pour alerter (1-5)
- `AlertOnHighRisk` : Alerter si risque ≥ 4
- `AlertOnSacrifice` : Alerter sur stratégies de sacrifice
- `AlertOnCelebre` : Alerter sur parties célèbres
- `AlertOnIncoherence` : Alerter sur incohérences détectées

### CSV Logging
- `EnableCSVLogging` : Activer les logs CSV
- `LogAllScans` : Logger tous les scans
- `LogOnlyAlerts` : Logger uniquement les alertes

## 📊 Fichiers CSV générés

Les fichiers CSV sont créés dans le dossier `MQL5/Files/` :

1. **CHESS160_Moves.csv**
   - Timestamp, Symbol, High/Low strategies
   - Prix, temps, cohérence, recommandation

2. **CHESS160_HighLow.csv**
   - Historique complet des HIGH/LOW
   - Analyse de range et volatilité

3. **CHESS160_Detections.csv**
   - Changements de stratégies détectés
   - Transitions HIGH → LOW

## 🎯 Concept CHESS-160

### Mapping 160 minutes → 64 cases

```
160 minutes / 64 cases = 2.5 minutes par case

Minute 0-2    → a1 (Gambit Dame)
Minute 3-5    → b1 (Défense Française)
...
Minute 157-159 → h8 (Coin h8 piégé)
```

### Phases de jeu

- **Rangées 1-2** : Ouverture (défensive et agressive)
- **Rangées 3-5** : Milieu de jeu (tactique et stratégique)
- **Rangées 6-8** : Finale (active et technique)

### Analyse de cohérence

Le système vérifie :
- ✅ Transitions de phase logiques
- ⚠️ Écarts de risque importants
- 🔴 Doubles sacrifices
- 🟢 Stratégies célèbres

### Recommandations

Selon la position du prix actuel dans le range HIGH-LOW :
- 🔴 **VENDRE** : Prix > 80% du range
- 🟠 **PRUDENCE** : Prix 60-80%
- 🟢 **NEUTRE** : Prix 40-60%
- 🟠 **ATTENTION** : Prix 20-40%
- 🔵 **ACHETER** : Prix < 20%

## 📱 Alertes Telegram

Format de l'alerte :
```
🔔 CHESS-160 ALERT
━━━━━━━━━━━━━━━━━━━

📊 Symbol: EURUSD
🕐 Time: 2025.01.13 14:30

⬆️ HIGH Strategy
   • Case: d5
   • Name: Avant-poste d5
   • Price: 1.08950
   • Phase: Milieu
   • Risk: 3/5
   • ⭐ Partie célèbre

⬇️ LOW Strategy
   • Case: a2
   • Name: Gambit Evans
   • Price: 1.08450
   • Phase: Ouverture
   • Risk: 4/5
   • 🔴 SACRIFICE

💹 Market Analysis
   • Current: 1.08700
   • Range: 50.0 pips
   • Position: 50.0%

🎯 NEUTRE - Milieu range (50.0%)

🔍 Coherence: ⚠️ INCOHÉRENT...
```

## 🔍 Exemples d'utilisation

### Scanner un seul symbole
```
ChessSymbolsList = "EURUSD"
ScanAllMarketWatch = false
```

### Scanner Market Watch toutes les 30 minutes
```
ScanAllMarketWatch = true
ScanIntervalMinutes = 30
```

### Alertes uniquement sur risque élevé
```
AlertOnHighRisk = true
AlertOnSacrifice = true
MinRiskThreshold = 4
```

## 📈 Performance

- Léger : scan rapide, pas de calculs lourds
- Timer-based : pas de charge sur OnTick()
- CSV optimisé : append mode, pas de réécriture
- Historique limité : max 1000 snapshots

## 🐛 Debugging

Mode verbeux pour diagnostics :
```
VerboseMode = true
ShowHistoryOnScan = true
```

Consulter le journal MetaTrader (onglet "Experts") pour :
- État des scans
- Erreurs Telegram
- Détection de changements
- Alertes envoyées

## ⚠️ Notes importantes

1. **Données requises** : Minimum 160 bougies M1 disponibles
2. **Market Watch** : Symboles doivent être dans le Market Watch
3. **Telegram** : URL doit être autorisée dans les options
4. **Timer** : Fonctionne uniquement si l'EA est attaché à un graphique

## 📝 Licence

Copyright © CHESS-160 System

## 🔗 Liens

- GitHub: https://github.com/chess160
- Documentation échecs : https://www.chess.com/learn

---

**Version 1.00** - Système complet de scanning et alertes

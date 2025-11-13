//+------------------------------------------------------------------+
//|                                                   CHESS_160.mq5 |
//|                          CHESS-160 - Scanner Stratégies Échecs  |
//|                          Scan 160 minutes / Alert 60 minutes     |
//+------------------------------------------------------------------+
#property copyright "CHESS-160 System"
#property link      "https://github.com/chess160"
#property version   "1.00"

#include <ChessEngine.mqh>
#include <CSVLogger.mqh>
#include <TelegramChess.mqh>
#include <HistoryTracker.mqh>

//--- Input parameters
input group "=== TELEGRAM ==="
input string TelegramToken = "";                    // Token Telegram Bot
input string TelegramChatID = "";                   // Chat ID Telegram
input bool EnableTelegramAlerts = true;             // Activer alertes Telegram

input group "=== SYMBOLES ==="
input string ChessSymbolsList = "";                 // Liste symboles (vide = Market Watch)
input bool ScanAllMarketWatch = true;               // Scanner tous Market Watch

input group "=== SCANNING ==="
input bool EnableAutoScan = true;                   // Activer scan automatique
input int ScanIntervalMinutes = 60;                 // Intervalle scan (minutes)
input bool ScanOnInit = true;                       // Scanner au démarrage

input group "=== FILTRES ==="
input int MinRiskThreshold = 3;                     // Seuil risque minimum alerte
input bool AlertOnHighRisk = true;                  // Alerter si risque >= 4
input bool AlertOnSacrifice = true;                 // Alerter si sacrifice détecté
input bool AlertOnCelebre = true;                   // Alerter si partie célèbre
input bool AlertOnIncoherence = true;               // Alerter si incohérent

input group "=== CSV LOGGING ==="
input bool EnableCSVLogging = true;                 // Activer logs CSV
input bool LogAllScans = true;                      // Logger tous les scans
input bool LogOnlyAlerts = false;                   // Logger uniquement alertes

input group "=== DEBUG ==="
input bool VerboseMode = false;                     // Mode verbeux
input bool ShowHistoryOnScan = false;               // Afficher historique à chaque scan

//--- Global objects
ChessEngine* chess;
CSVLogger* logger;
TelegramChess* telegram;
HistoryTracker* tracker;

//--- Global variables
datetime last_scan_time = 0;
int total_scans = 0;
int total_alerts = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   Print("♟️  CHESS-160 EA - INITIALISATION");
   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

   // Initialize objects
   chess = new ChessEngine();
   logger = new CSVLogger();
   telegram = new TelegramChess();
   tracker = new HistoryTracker();

   Print("✅ ChessEngine: 64 stratégies chargées");
   Print("✅ CSVLogger: Prêt");
   Print("✅ TelegramChess: Prêt");
   Print("✅ HistoryTracker: Prêt");

   // Check Telegram config
   if(EnableTelegramAlerts)
   {
      if(TelegramToken == "" || TelegramChatID == "")
      {
         Print("⚠️ ALERTE: Token ou ChatID Telegram vide");
         Print("   Les alertes Telegram sont désactivées");
      }
      else
      {
         Print("✅ Telegram configuré");
      }
   }

   // Setup timer
   if(EnableAutoScan)
   {
      int interval_seconds = ScanIntervalMinutes * 60;
      EventSetTimer(interval_seconds);
      Print("✅ Timer configuré: scan toutes les ", ScanIntervalMinutes, " minutes");
   }

   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   Print("🚀 CHESS-160 démarré avec succès");
   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

   // Premier scan immédiat si demandé
   if(ScanOnInit)
   {
      Print("🔍 Lancement scan initial...\n");
      OnTimer();
   }

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   Print("♟️  CHESS-160 EA - ARRÊT");
   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   Print("Total scans effectués: ", total_scans);
   Print("Total alertes envoyées: ", total_alerts);
   Print("Historique conservé: ", tracker->GetHistoryCount(), " snapshots");

   EventKillTimer();

   delete chess;
   delete logger;
   delete telegram;
   delete tracker;

   Print("✅ Objets libérés");
   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
}

//+------------------------------------------------------------------+
//| Timer function - Scan périodique                                |
//+------------------------------------------------------------------+
void OnTimer()
{
   datetime now = TimeCurrent();

   Print("\n╔════════════════════════════════════════╗");
   Print("║  🔍 SCAN CHESS-160 - ", TimeToString(now, TIME_MINUTES), "  ║");
   Print("╚════════════════════════════════════════╝\n");

   total_scans++;
   last_scan_time = now;

   // Obtenir liste symboles
   string symbols[];
   GetSymbolsList(symbols);

   int count = ArraySize(symbols);
   Print("📊 ", count, " symbole(s) à scanner\n");

   // Scanner chaque symbole
   for(int i = 0; i < count; i++)
   {
      ScanSymbol(symbols[i]);

      if(VerboseMode)
         Print("---");
   }

   Print("\n✅ Scan terminé: ", count, " symbole(s) analysé(s)");
   Print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

   // Afficher historique si demandé
   if(ShowHistoryOnScan)
   {
      tracker->PrintHistory(5);
   }
}

//+------------------------------------------------------------------+
//| Get symbols list                                                 |
//+------------------------------------------------------------------+
void GetSymbolsList(string &symbols[])
{
   ArrayResize(symbols, 0);

   if(ChessSymbolsList != "" && !ScanAllMarketWatch)
   {
      // Parser liste manuelle
      string list = ChessSymbolsList;
      StringReplace(list, " ", "");

      string temp[];
      int parts = StringSplit(list, ',', temp);

      for(int i = 0; i < parts; i++)
      {
         if(temp[i] != "")
         {
            int size = ArraySize(symbols);
            ArrayResize(symbols, size + 1);
            symbols[size] = temp[i];
         }
      }
   }
   else
   {
      // Scanner Market Watch
      int total = SymbolsTotal(true);

      for(int i = 0; i < total; i++)
      {
         string sym = SymbolName(i, true);

         if(sym != "")
         {
            int size = ArraySize(symbols);
            ArrayResize(symbols, size + 1);
            symbols[size] = sym;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Scan single symbol                                               |
//+------------------------------------------------------------------+
void ScanSymbol(string symbol)
{
   if(VerboseMode)
      Print("🔎 Analyse: ", symbol);

   // Vérifier que le symbole existe
   if(!SymbolSelect(symbol, true))
   {
      Print("⚠️ Symbole introuvable: ", symbol);
      return;
   }

   datetime now = TimeCurrent();
   datetime start = now - (160 * 60); // 160 minutes

   // Copier 160 bougies M1
   MqlRates rates[];
   int copied = CopyRates(symbol, PERIOD_M1, start, 160, rates);

   if(copied < 160)
   {
      if(VerboseMode)
         Print("⚠️ ", symbol, ": seulement ", copied, " bougies disponibles (160 requis)");
      return;
   }

   // Trouver HIGH et LOW
   double high_price = rates[0].high;
   datetime high_time = rates[0].time;
   int high_idx = 0;

   double low_price = rates[0].low;
   datetime low_time = rates[0].time;
   int low_idx = 0;

   for(int i = 1; i < 160; i++)
   {
      if(rates[i].high > high_price)
      {
         high_price = rates[i].high;
         high_time = rates[i].time;
         high_idx = i;
      }

      if(rates[i].low < low_price)
      {
         low_price = rates[i].low;
         low_time = rates[i].time;
         low_idx = i;
      }
   }

   // Mapper sur stratégies
   ChessStrategy high_strat = chess->GetStrategyByMinute(high_idx);
   ChessStrategy low_strat = chess->GetStrategyByMinute(low_idx);

   if(high_strat.case_id == "" || low_strat.case_id == "")
   {
      Print("❌ ", symbol, ": Stratégies introuvables");
      return;
   }

   // Prix actuel
   double cur_price = SymbolInfoDouble(symbol, SYMBOL_BID);

   // Analyser cohérence
   string coherence = chess->AnalyzeCoherence(high_strat, low_strat);

   // Recommandation
   string reco = chess->GetRecommendation(cur_price, high_price, low_price);

   // Stats
   int delta_risk = MathAbs(high_strat.risque - low_strat.risque);
   double avg_comp = (high_strat.complexite + low_strat.complexite) / 2.0;
   string phase_trans = high_strat.phase + "→" + low_strat.phase;

   if(VerboseMode)
   {
      Print("   HIGH: ", high_strat.case_id, " (", high_strat.nom, ") - ", high_idx, "mn");
      Print("   LOW:  ", low_strat.case_id, " (", low_strat.nom, ") - ", low_idx, "mn");
      Print("   ", coherence);
   }

   // Déterminer priorité alerte
   string priority = "LOW";
   bool should_alert = false;

   // Vérifier conditions d'alerte
   if(AlertOnHighRisk && (high_strat.risque >= 4 || low_strat.risque >= 4))
   {
      priority = "HIGH";
      should_alert = true;
   }

   if(AlertOnSacrifice && (chess->IsSacrificeStrategy(high_strat) || chess->IsSacrificeStrategy(low_strat)))
   {
      priority = "HIGH";
      should_alert = true;
   }

   if(AlertOnCelebre && (chess->IsCelebreStrategy(high_strat) || chess->IsCelebreStrategy(low_strat)))
   {
      priority = "MEDIUM";
      should_alert = true;
   }

   if(AlertOnIncoherence && StringFind(coherence, "INCOHÉRENT") >= 0)
   {
      priority = "MEDIUM";
      should_alert = true;
   }

   if(high_strat.risque >= MinRiskThreshold || low_strat.risque >= MinRiskThreshold)
   {
      should_alert = true;
      if(priority == "LOW")
         priority = "MEDIUM";
   }

   // CSV Logging
   if(EnableCSVLogging)
   {
      if(LogAllScans || (LogOnlyAlerts && should_alert))
      {
         logger->LogMove(symbol, high_strat.case_id, low_strat.case_id,
                       high_strat.nom, low_strat.nom,
                       high_price, low_price,
                       high_time, low_time,
                       coherence, delta_risk, avg_comp,
                       phase_trans, reco, priority);

         logger->LogHighLowHistory(symbol, start, now,
                                 high_price, high_time, high_idx, high_strat.case_id,
                                 low_price, low_time, low_idx, low_strat.case_id,
                                 cur_price, 0, 0);
      }
   }

   // Telegram Alert
   if(EnableTelegramAlerts && should_alert && TelegramToken != "" && TelegramChatID != "")
   {
      telegram->SendChessAlert(symbol,
                             high_strat, low_strat,
                             high_price, high_time, high_idx,
                             low_price, low_time, low_idx,
                             cur_price, coherence, reco,
                             TelegramToken, TelegramChatID);

      total_alerts++;
      Print("📱 Alerte Telegram envoyée: ", symbol, " (", priority, ")");
   }

   // Tracker
   tracker->AddSnapshot(high_price, high_time, high_idx, high_strat.case_id,
                      low_price, low_time, low_idx, low_strat.case_id,
                      cur_price, symbol);

   // Détecter changements
   if(tracker->DetectStrategyChange(symbol, high_strat.case_id, "HIGH"))
   {
      if(EnableCSVLogging)
      {
         logger->LogStrategyDetection(symbol, high_strat.case_id, high_strat.nom,
                                    high_strat.phase, high_strat.risque,
                                    high_strat.complexite, high_strat.principe,
                                    high_time, "HIGH_CHANGE");
      }
   }

   if(tracker->DetectStrategyChange(symbol, low_strat.case_id, "LOW"))
   {
      if(EnableCSVLogging)
      {
         logger->LogStrategyDetection(symbol, low_strat.case_id, low_strat.nom,
                                    low_strat.phase, low_strat.risque,
                                    low_strat.complexite, low_strat.principe,
                                    low_time, "LOW_CHANGE");
      }
   }
}

//+------------------------------------------------------------------+
//| Expert tick function (not used - timer-based)                   |
//+------------------------------------------------------------------+
void OnTick()
{
   // Scan timer-based uniquement
}
//+------------------------------------------------------------------+

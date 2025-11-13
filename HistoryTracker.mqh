//+------------------------------------------------------------------+
//|                                             HistoryTracker.mqh   |
//|                          CHESS-160 History Tracker               |
//+------------------------------------------------------------------+
#property copyright "CHESS-160 System"

//+------------------------------------------------------------------+
//| Structure pour snapshot historique                              |
//+------------------------------------------------------------------+
struct HistorySnapshot
{
   datetime timestamp;
   string symbol;
   double high_price;
   datetime high_time;
   int high_minute;
   string high_case;
   double low_price;
   datetime low_time;
   int low_minute;
   string low_case;
   double current_price;
};

//+------------------------------------------------------------------+
//| Structure pour tracking par symbole                             |
//+------------------------------------------------------------------+
struct SymbolTracking
{
   string symbol;
   string last_high_case;
   string last_low_case;
   datetime last_update;
};

//+------------------------------------------------------------------+
//| Classe HistoryTracker                                            |
//+------------------------------------------------------------------+
class HistoryTracker
{
private:
   HistorySnapshot snapshots[];
   SymbolTracking tracking[];
   int max_snapshots;

   int FindSymbolTracking(string symbol)
   {
      for(int i = 0; i < ArraySize(tracking); i++)
      {
         if(tracking[i].symbol == symbol)
            return i;
      }
      return -1;
   }

   void AddSymbolTracking(string symbol, string high_case, string low_case)
   {
      int size = ArraySize(tracking);
      ArrayResize(tracking, size + 1);

      tracking[size].symbol = symbol;
      tracking[size].last_high_case = high_case;
      tracking[size].last_low_case = low_case;
      tracking[size].last_update = TimeCurrent();
   }

   void UpdateSymbolTracking(int index, string high_case, string low_case)
   {
      if(index >= 0 && index < ArraySize(tracking))
      {
         tracking[index].last_high_case = high_case;
         tracking[index].last_low_case = low_case;
         tracking[index].last_update = TimeCurrent();
      }
   }

public:
   HistoryTracker()
   {
      max_snapshots = 1000; // Garder les 1000 derniers snapshots
      ArrayResize(snapshots, 0);
      ArrayResize(tracking, 0);
   }

   ~HistoryTracker() {}

   void AddSnapshot(double high_price, datetime high_time, int high_minute, string high_case,
                    double low_price, datetime low_time, int low_minute, string low_case,
                    double current_price, string symbol)
   {
      int size = ArraySize(snapshots);

      // Limiter la taille
      if(size >= max_snapshots)
      {
         // Supprimer le plus ancien
         for(int i = 0; i < size - 1; i++)
         {
            snapshots[i] = snapshots[i + 1];
         }
         size = max_snapshots - 1;
      }

      ArrayResize(snapshots, size + 1);

      snapshots[size].timestamp = TimeCurrent();
      snapshots[size].symbol = symbol;
      snapshots[size].high_price = high_price;
      snapshots[size].high_time = high_time;
      snapshots[size].high_minute = high_minute;
      snapshots[size].high_case = high_case;
      snapshots[size].low_price = low_price;
      snapshots[size].low_time = low_time;
      snapshots[size].low_minute = low_minute;
      snapshots[size].low_case = low_case;
      snapshots[size].current_price = current_price;
   }

   bool DetectStrategyChange(string symbol, string current_case, string type)
   {
      int idx = FindSymbolTracking(symbol);

      if(idx < 0)
      {
         // Première fois qu'on track ce symbole
         AddSymbolTracking(symbol,
                          type == "HIGH" ? current_case : "",
                          type == "LOW" ? current_case : "");
         return false; // Pas de changement, première détection
      }

      bool changed = false;

      if(type == "HIGH")
      {
         if(tracking[idx].last_high_case != current_case && tracking[idx].last_high_case != "")
         {
            changed = true;
            Print("🔄 ", symbol, ": HIGH strategy changed: ",
                  tracking[idx].last_high_case, " → ", current_case);
         }
         tracking[idx].last_high_case = current_case;
      }
      else if(type == "LOW")
      {
         if(tracking[idx].last_low_case != current_case && tracking[idx].last_low_case != "")
         {
            changed = true;
            Print("🔄 ", symbol, ": LOW strategy changed: ",
                  tracking[idx].last_low_case, " → ", current_case);
         }
         tracking[idx].last_low_case = current_case;
      }

      tracking[idx].last_update = TimeCurrent();

      return changed;
   }

   int GetHistoryCount()
   {
      return ArraySize(snapshots);
   }

   void PrintHistory(int last_n = 10)
   {
      int count = ArraySize(snapshots);
      if(count == 0)
      {
         Print("📊 Aucun historique disponible");
         return;
      }

      Print("\n╔═══════════════════════════════════════════════╗");
      Print("║       📊 HISTORIQUE (", last_n, " derniers)          ║");
      Print("╚═══════════════════════════════════════════════╝\n");

      int start = MathMax(0, count - last_n);

      for(int i = start; i < count; i++)
      {
         Print("[", TimeToString(snapshots[i].timestamp, TIME_MINUTES), "] ", snapshots[i].symbol);
         Print("   HIGH: ", snapshots[i].high_case, " @ ", DoubleToString(snapshots[i].high_price, 5));
         Print("   LOW:  ", snapshots[i].low_case, " @ ", DoubleToString(snapshots[i].low_price, 5));
         Print("   CUR:  ", DoubleToString(snapshots[i].current_price, 5));
         Print("   ---");
      }

      Print("");
   }

   void ClearHistory()
   {
      ArrayResize(snapshots, 0);
      ArrayResize(tracking, 0);
      Print("✅ Historique effacé");
   }

   // Obtenir dernier snapshot pour un symbole
   bool GetLastSnapshot(string symbol, HistorySnapshot &snap)
   {
      for(int i = ArraySize(snapshots) - 1; i >= 0; i--)
      {
         if(snapshots[i].symbol == symbol)
         {
            snap = snapshots[i];
            return true;
         }
      }
      return false;
   }
};
//+------------------------------------------------------------------+

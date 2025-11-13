//+------------------------------------------------------------------+
//|                                                   CSVLogger.mqh  |
//|                          CHESS-160 CSV Logger                    |
//+------------------------------------------------------------------+
#property copyright "CHESS-160 System"
#property strict

//+------------------------------------------------------------------+
//| Classe CSVLogger                                                 |
//+------------------------------------------------------------------+
class CSVLogger
{
private:
   string moves_file;
   string history_file;
   string detection_file;

   void InitFiles()
   {
      moves_file = "CHESS160_Moves.csv";
      history_file = "CHESS160_HighLow.csv";
      detection_file = "CHESS160_Detections.csv";

      // Créer headers si fichiers n'existent pas
      if(!FileIsExist(moves_file))
         CreateMovesFile();

      if(!FileIsExist(history_file))
         CreateHistoryFile();

      if(!FileIsExist(detection_file))
         CreateDetectionFile();
   }

   void CreateMovesFile()
   {
      int handle = FileOpen(moves_file, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE)
      {
         FileWrite(handle,
                   "Timestamp",
                   "Symbol",
                   "High_Case",
                   "Low_Case",
                   "High_Strategy",
                   "Low_Strategy",
                   "High_Price",
                   "Low_Price",
                   "High_Time",
                   "Low_Time",
                   "Coherence",
                   "Delta_Risk",
                   "Avg_Complexity",
                   "Phase_Transition",
                   "Recommendation",
                   "Priority");
         FileClose(handle);
      }
   }

   void CreateHistoryFile()
   {
      int handle = FileOpen(history_file, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE)
      {
         FileWrite(handle,
                   "Timestamp",
                   "Symbol",
                   "Period_Start",
                   "Period_End",
                   "High_Price",
                   "High_Time",
                   "High_Minute",
                   "High_Case",
                   "Low_Price",
                   "Low_Time",
                   "Low_Minute",
                   "Low_Case",
                   "Current_Price",
                   "Range_Percent",
                   "Volatility");
         FileClose(handle);
      }
   }

   void CreateDetectionFile()
   {
      int handle = FileOpen(detection_file, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE)
      {
         FileWrite(handle,
                   "Timestamp",
                   "Symbol",
                   "Case_ID",
                   "Strategy_Name",
                   "Phase",
                   "Risk",
                   "Complexity",
                   "Principle",
                   "Detection_Time",
                   "Type");
         FileClose(handle);
      }
   }

public:
   CSVLogger()
   {
      InitFiles();
   }

   ~CSVLogger() {}

   // Logger un mouvement (High/Low)
   void LogMove(string symbol,
                string high_case, string low_case,
                string high_name, string low_name,
                double high_price, double low_price,
                datetime high_time, datetime low_time,
                string coherence,
                int delta_risk, double avg_complexity,
                string phase_trans, string reco, string priority)
   {
      int handle = FileOpen(moves_file, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE)
      {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle,
                   TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
                   symbol,
                   high_case,
                   low_case,
                   high_name,
                   low_name,
                   DoubleToString(high_price, 5),
                   DoubleToString(low_price, 5),
                   TimeToString(high_time, TIME_DATE|TIME_MINUTES),
                   TimeToString(low_time, TIME_DATE|TIME_MINUTES),
                   coherence,
                   IntegerToString(delta_risk),
                   DoubleToString(avg_complexity, 2),
                   phase_trans,
                   reco,
                   priority);
         FileClose(handle);
      }
   }

   // Logger historique High/Low
   void LogHighLowHistory(string symbol,
                          datetime period_start, datetime period_end,
                          double high_price, datetime high_time, int high_minute, string high_case,
                          double low_price, datetime low_time, int low_minute, string low_case,
                          double current_price,
                          double range_percent, double volatility)
   {
      int handle = FileOpen(history_file, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE)
      {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle,
                   TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
                   symbol,
                   TimeToString(period_start, TIME_DATE|TIME_MINUTES),
                   TimeToString(period_end, TIME_DATE|TIME_MINUTES),
                   DoubleToString(high_price, 5),
                   TimeToString(high_time, TIME_DATE|TIME_MINUTES),
                   IntegerToString(high_minute),
                   high_case,
                   DoubleToString(low_price, 5),
                   TimeToString(low_time, TIME_DATE|TIME_MINUTES),
                   IntegerToString(low_minute),
                   low_case,
                   DoubleToString(current_price, 5),
                   DoubleToString(range_percent, 2),
                   DoubleToString(volatility, 5));
         FileClose(handle);
      }
   }

   // Logger détection stratégie
   void LogStrategyDetection(string symbol,
                            string case_id, string strategy_name,
                            string phase, int risk, double complexity,
                            string principle,
                            datetime detection_time, string type)
   {
      int handle = FileOpen(detection_file, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE)
      {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle,
                   TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
                   symbol,
                   case_id,
                   strategy_name,
                   phase,
                   IntegerToString(risk),
                   DoubleToString(complexity, 2),
                   principle,
                   TimeToString(detection_time, TIME_DATE|TIME_MINUTES),
                   type);
         FileClose(handle);
      }
   }
};
//+------------------------------------------------------------------+

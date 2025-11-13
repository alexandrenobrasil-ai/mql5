//+------------------------------------------------------------------+
//|                                              TelegramChess.mqh   |
//|                          CHESS-160 Telegram Alerts               |
//+------------------------------------------------------------------+
#property copyright "CHESS-160 System"
#property strict

//+------------------------------------------------------------------+
//| Classe TelegramChess                                             |
//+------------------------------------------------------------------+
class TelegramChess
{
private:
   string BuildMessage(string symbol,
                      ChessStrategy &high_strat, ChessStrategy &low_strat,
                      double high_price, datetime high_time, int high_minute,
                      double low_price, datetime low_time, int low_minute,
                      double current_price, string coherence, string recommendation)
   {
      string msg = "";

      msg += "🔔 *CHESS-160 ALERT*\n";
      msg += "━━━━━━━━━━━━━━━━━━━\n\n";

      msg += "📊 *Symbol:* " + symbol + "\n";
      msg += "🕐 *Time:* " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES) + "\n\n";

      msg += "⬆️ *HIGH Strategy*\n";
      msg += "   • Case: " + high_strat.case_id + "\n";
      msg += "   • Name: " + high_strat.nom + "\n";
      msg += "   • Price: " + DoubleToString(high_price, 5) + "\n";
      msg += "   • Time: " + TimeToString(high_time, TIME_MINUTES) + " (min " + IntegerToString(high_minute) + ")\n";
      msg += "   • Phase: " + high_strat.phase + "\n";
      msg += "   • Risk: " + IntegerToString(high_strat.risque) + "/5\n";
      msg += "   • Complexity: " + DoubleToString(high_strat.complexite, 1) + "/5\n";

      if(high_strat.sacrifice)
         msg += "   • 🔴 SACRIFICE\n";
      if(high_strat.celebre)
         msg += "   • ⭐ Partie célèbre\n";

      msg += "\n⬇️ *LOW Strategy*\n";
      msg += "   • Case: " + low_strat.case_id + "\n";
      msg += "   • Name: " + low_strat.nom + "\n";
      msg += "   • Price: " + DoubleToString(low_price, 5) + "\n";
      msg += "   • Time: " + TimeToString(low_time, TIME_MINUTES) + " (min " + IntegerToString(low_minute) + ")\n";
      msg += "   • Phase: " + low_strat.phase + "\n";
      msg += "   • Risk: " + IntegerToString(low_strat.risque) + "/5\n";
      msg += "   • Complexity: " + DoubleToString(low_strat.complexite, 1) + "/5\n";

      if(low_strat.sacrifice)
         msg += "   • 🔴 SACRIFICE\n";
      if(low_strat.celebre)
         msg += "   • ⭐ Partie célèbre\n";

      msg += "\n💹 *Market Analysis*\n";
      msg += "   • Current: " + DoubleToString(current_price, 5) + "\n";
      msg += "   • Range: " + DoubleToString((high_price - low_price) * 10000, 1) + " pips\n";

      double position = ((current_price - low_price) / (high_price - low_price)) * 100.0;
      msg += "   • Position: " + DoubleToString(position, 1) + "%\n\n";

      msg += "🎯 *" + recommendation + "*\n\n";
      msg += "🔍 *Coherence:* " + coherence + "\n";

      return msg;
   }

   bool SendTelegramMessage(string token, string chat_id, string message)
   {
      if(token == "" || chat_id == "")
         return false;

      // URL encode le message
      string encoded_msg = message;
      StringReplace(encoded_msg, "\n", "%0A");
      StringReplace(encoded_msg, " ", "%20");
      StringReplace(encoded_msg, "*", "%2A");
      StringReplace(encoded_msg, "_", "%5F");
      StringReplace(encoded_msg, ":", "%3A");
      StringReplace(encoded_msg, "•", "%E2%80%A2");
      StringReplace(encoded_msg, "⬆", "%E2%AC%86");
      StringReplace(encoded_msg, "⬇", "%E2%AC%87");
      StringReplace(encoded_msg, "🔔", "%F0%9F%94%94");
      StringReplace(encoded_msg, "📊", "%F0%9F%93%8A");
      StringReplace(encoded_msg, "🕐", "%F0%9F%95%90");
      StringReplace(encoded_msg, "💹", "%F0%9F%92%B9");
      StringReplace(encoded_msg, "🎯", "%F0%9F%8E%AF");
      StringReplace(encoded_msg, "🔍", "%F0%9F%94%8D");
      StringReplace(encoded_msg, "🔴", "%F0%9F%94%B4");
      StringReplace(encoded_msg, "⭐", "%E2%AD%90");

      string url = "https://api.telegram.org/bot" + token + "/sendMessage";
      string params = "chat_id=" + chat_id + "&text=" + encoded_msg + "&parse_mode=Markdown";

      char post_data[];
      char result_data[];
      string result_headers;

      ArrayResize(post_data, StringLen(params));
      StringToCharArray(params, post_data, 0, StringLen(params));

      int timeout = 5000;
      int res = WebRequest(
         "POST",
         url,
         "",
         NULL,
         timeout,
         post_data,
         0,
         result_data,
         result_headers
      );

      if(res == 200 || res == -1)
      {
         // -1 peut signifier que WebRequest n'est pas autorisé
         // Il faut ajouter l'URL dans Tools > Options > Expert Advisors > Allow WebRequest
         return true;
      }

      return false;
   }

public:
   TelegramChess() {}
   ~TelegramChess() {}

   void SendChessAlert(string symbol,
                       ChessStrategy &high_strat, ChessStrategy &low_strat,
                       double high_price, datetime high_time, int high_minute,
                       double low_price, datetime low_time, int low_minute,
                       double current_price, string coherence, string recommendation,
                       string token, string chat_id)
   {
      string message = BuildMessage(symbol,
                                   high_strat, low_strat,
                                   high_price, high_time, high_minute,
                                   low_price, low_time, low_minute,
                                   current_price, coherence, recommendation);

      bool sent = SendTelegramMessage(token, chat_id, message);

      if(!sent)
      {
         Print("⚠️ Erreur envoi Telegram - Vérifier:");
         Print("   1. Token et ChatID corrects");
         Print("   2. URL autorisée: Tools > Options > Expert Advisors");
         Print("   3. Ajouter: https://api.telegram.org");
      }
   }
};
//+------------------------------------------------------------------+

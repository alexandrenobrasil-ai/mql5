//+------------------------------------------------------------------+
//|                                                ChessEngine.mqh   |
//|                          CHESS-160 Engine - 64 Stratégies       |
//+------------------------------------------------------------------+
#property copyright "CHESS-160 System"

//+------------------------------------------------------------------+
//| Structure pour une stratégie d'échecs                           |
//+------------------------------------------------------------------+
struct ChessStrategy
{
   string case_id;          // ID de la case (a1-h8)
   string nom;              // Nom de la stratégie
   string phase;            // Phase du jeu (Ouverture, Milieu, Finale)
   int risque;              // Niveau de risque (1-5)
   double complexite;       // Complexité (1-5)
   string principe;         // Principe de la stratégie
   bool sacrifice;          // Stratégie de sacrifice?
   bool celebre;            // Partie célèbre associée?
};

//+------------------------------------------------------------------+
//| Classe ChessEngine                                               |
//+------------------------------------------------------------------+
class ChessEngine
{
private:
   ChessStrategy strategies[64];

   void SetStrategy(int idx, string cid, string n, string ph, int r, double c, string pr, bool s, bool ce)
   {
      strategies[idx].case_id = cid;
      strategies[idx].nom = n;
      strategies[idx].phase = ph;
      strategies[idx].risque = r;
      strategies[idx].complexite = c;
      strategies[idx].principe = pr;
      strategies[idx].sacrifice = s;
      strategies[idx].celebre = ce;
   }

   void InitializeStrategies()
   {
      // Rangée 1 (a1-h1) - Ouverture défensive
      SetStrategy(0, "a1", "Gambit Dame", "Ouverture", 4, 4.5, "Sacrifice pion pour initiative", true, true);
      SetStrategy(1, "b1", "Défense Française", "Ouverture", 2, 3.0, "Structure solide", false, true);
      SetStrategy(2, "c1", "Défense Sicilienne", "Ouverture", 3, 4.0, "Contre-attaque", false, true);
      SetStrategy(3, "d1", "Gambit Roi", "Ouverture", 5, 4.5, "Attaque agressive", true, true);
      SetStrategy(4, "e1", "Partie Espagnole", "Ouverture", 2, 3.5, "Pression durable", false, true);
      SetStrategy(5, "f1", "Défense Caro-Kann", "Ouverture", 2, 3.0, "Solide et flexible", false, true);
      SetStrategy(6, "g1", "Attaque Fegatello", "Ouverture", 4, 4.0, "Sacrifice cavalier", true, true);
      SetStrategy(7, "h1", "Défense Alekhine", "Ouverture", 3, 3.5, "Provocation", false, true);

      // Rangée 2 (a2-h2) - Ouverture agressive
      SetStrategy(8, "a2", "Gambit Evans", "Ouverture", 4, 4.0, "Sacrifice fou", true, true);
      SetStrategy(9, "b2", "Attaque Fried Liver", "Ouverture", 5, 4.5, "Attaque sur f7", true, true);
      SetStrategy(10, "c2", "Défense Nimzo-Indienne", "Ouverture", 2, 4.0, "Contrôle centre", false, true);
      SetStrategy(11, "d2", "Gambit Budapest", "Ouverture", 4, 3.5, "Contre-gambit", true, false);
      SetStrategy(12, "e2", "Ouverture Italienne", "Ouverture", 2, 3.0, "Développement rapide", false, true);
      SetStrategy(13, "f2", "Dragon Sicilien", "Ouverture", 4, 4.5, "Attaque roque opposé", false, true);
      SetStrategy(14, "g2", "Défense Benoni", "Ouverture", 3, 4.0, "Déséquilibre pions", false, false);
      SetStrategy(15, "h2", "Attaque King's Indian", "Ouverture", 3, 4.0, "Attaque flanc roi", false, true);

      // Rangée 3 (a3-h3) - Transition ouverture-milieu
      SetStrategy(16, "a3", "Plan Minoritaire", "Milieu", 2, 3.5, "Attaque minorité", false, false);
      SetStrategy(17, "b3", "Sacrifice Qualité", "Milieu", 4, 4.0, "Tour contre pièce mineure", true, false);
      SetStrategy(18, "c3", "Manoeuvre Nd5", "Milieu", 3, 3.5, "Avant-poste cavalier", false, false);
      SetStrategy(19, "d3", "Clouage Dame", "Milieu", 3, 3.0, "Clouage tactique", false, false);
      SetStrategy(20, "e3", "Pression Colonne e", "Milieu", 2, 3.0, "Contrôle colonne", false, false);
      SetStrategy(21, "f3", "Attaque Greco", "Milieu", 4, 4.5, "Sacrifice Fxh7+", true, true);
      SetStrategy(22, "g3", "Fianchetto Défensif", "Milieu", 1, 2.5, "Structure défensive", false, false);
      SetStrategy(23, "h3", "Poussée h4-h5", "Milieu", 3, 3.0, "Attaque flanc", false, false);

      // Rangée 4 (a4-h4) - Milieu de jeu tactique
      SetStrategy(24, "a4", "Percée a4-a5", "Milieu", 3, 3.0, "Attaque flanc dame", false, false);
      SetStrategy(25, "b4", "Sacrifice Bxh7+", "Milieu", 5, 4.5, "Sacrifice fou classique", true, true);
      SetStrategy(26, "c4", "Contrôle c4-d5", "Milieu", 2, 3.5, "Cases clés", false, false);
      SetStrategy(27, "d4", "Percée d4-d5", "Milieu", 3, 3.5, "Rupture centrale", false, false);
      SetStrategy(28, "e4", "Attaque Centrale", "Milieu", 3, 3.5, "Domination centre", false, false);
      SetStrategy(29, "f4", "Attaque Lasker", "Milieu", 4, 4.0, "Sacrifice Ng5-h7", true, true);
      SetStrategy(30, "g4", "Poussée g4-g5", "Milieu", 4, 3.5, "Attaque agressive", false, false);
      SetStrategy(31, "h4", "Sacrifice Rxh7", "Milieu", 5, 5.0, "Sacrifice tour", true, false);

      // Rangée 5 (a5-h5) - Milieu de jeu stratégique
      SetStrategy(32, "a5", "Verrou a5-b6", "Milieu", 2, 3.0, "Blocage flanc", false, false);
      SetStrategy(33, "b5", "Avant-poste b5", "Milieu", 3, 3.5, "Pièce avancée", false, false);
      SetStrategy(34, "c5", "Blocage c5", "Milieu", 2, 3.0, "Contrôle case", false, false);
      SetStrategy(35, "d5", "Avant-poste d5", "Milieu", 3, 4.0, "Case clé centrale", false, false);
      SetStrategy(36, "e5", "Avant-poste e5", "Milieu", 3, 4.0, "Domination centre", false, false);
      SetStrategy(37, "f5", "Percée f5-f6", "Milieu", 4, 3.5, "Attaque roi", false, false);
      SetStrategy(38, "g5", "Clouage g5", "Milieu", 3, 3.0, "Pression pièce", false, false);
      SetStrategy(39, "h5", "Menace h5-h6", "Milieu", 3, 3.0, "Affaiblissement", false, false);

      // Rangée 6 (a6-h6) - Transition milieu-finale
      SetStrategy(40, "a6", "Structure a6-b5-c6", "Finale", 2, 3.0, "Chaîne pions", false, false);
      SetStrategy(41, "b6", "Pion passé b6", "Finale", 3, 3.5, "Pion avancé", false, false);
      SetStrategy(42, "c6", "Forteresse c6-d6", "Finale", 1, 3.0, "Défense passive", false, false);
      SetStrategy(43, "d6", "Pion passé d6", "Finale", 3, 3.5, "Pion dangereux", false, false);
      SetStrategy(44, "e6", "Blocage e6", "Finale", 2, 3.0, "Contrôle case", false, false);
      SetStrategy(45, "f6", "Roi actif f6", "Finale", 2, 3.0, "Centralisation roi", false, false);
      SetStrategy(46, "g6", "Structure g6-h7", "Finale", 1, 2.5, "Sécurité roi", false, false);
      SetStrategy(47, "h6", "Pion h6 isolé", "Finale", 2, 2.5, "Faiblesse", false, false);

      // Rangée 7 (a7-h7) - Finale active
      SetStrategy(48, "a7", "Pion dame 7ème", "Finale", 4, 4.0, "Promotion proche", false, false);
      SetStrategy(49, "b7", "Pion passé protégé", "Finale", 3, 3.5, "Pion soutenu", false, false);
      SetStrategy(50, "c7", "Pion c7 avancé", "Finale", 3, 3.5, "Menace promotion", false, false);
      SetStrategy(51, "d7", "Pion central 7ème", "Finale", 4, 4.0, "Très dangereux", false, false);
      SetStrategy(52, "e7", "Pion e7 bloqué", "Finale", 2, 3.0, "Blocage stratégique", false, false);
      SetStrategy(53, "f7", "Point faible f7", "Finale", 5, 4.5, "Attaque décisive", false, true);
      SetStrategy(54, "g7", "Roi g7 actif", "Finale", 2, 3.0, "Roi en jeu", false, false);
      SetStrategy(55, "h7", "Pion h7 promotionnel", "Finale", 4, 4.0, "Course promotion", false, false);

      // Rangée 8 (a8-h8) - Finale technique
      SetStrategy(56, "a8", "Tour 8ème rangée", "Finale", 3, 4.0, "Domination tour", false, false);
      SetStrategy(57, "b8", "Promotion b8", "Finale", 5, 5.0, "Transformation", false, false);
      SetStrategy(58, "c8", "Mat couloir c8", "Finale", 5, 4.5, "Mat imminent", false, true);
      SetStrategy(59, "d8", "Dame d8 dominante", "Finale", 4, 4.5, "Pièce puissante", false, false);
      SetStrategy(60, "e8", "Roi e8 acculé", "Finale", 5, 4.0, "Position critique", false, false);
      SetStrategy(61, "f8", "Mat Philidor", "Finale", 5, 5.0, "Mat classique", false, true);
      SetStrategy(62, "g8", "Mat du couloir", "Finale", 5, 4.5, "Mat arrière", false, true);
      SetStrategy(63, "h8", "Coin h8 piégé", "Finale", 5, 4.5, "Roi acculé", false, false);
   }

public:
   ChessEngine()
   {
      InitializeStrategies();
   }

   ~ChessEngine() {}

   // Obtenir stratégie par minute (0-159 -> 0-63)
   ChessStrategy GetStrategyByMinute(int minute)
   {
      ChessStrategy empty;
      empty.case_id = "";
      empty.nom = "";
      empty.phase = "";
      empty.risque = 0;
      empty.complexite = 0;
      empty.principe = "";
      empty.sacrifice = false;
      empty.celebre = false;

      if(minute < 0 || minute >= 160)
         return empty;

      // Mapper 160 minutes sur 64 cases
      // 160 / 64 = 2.5 minutes par case
      int index = (int)MathFloor(minute * 64.0 / 160.0);

      if(index < 0 || index >= 64)
         return empty;

      return strategies[index];
   }

   // Analyser cohérence entre 2 stratégies
   string AnalyzeCoherence(const ChessStrategy &high, const ChessStrategy &low)
   {
      // Vérifier transition de phase
      bool phase_ok = true;

      if(high.phase == "Ouverture" && low.phase == "Finale")
         phase_ok = false;

      if(high.phase == "Finale" && low.phase == "Ouverture")
         phase_ok = false;

      // Vérifier écart de risque
      int delta_risk = MathAbs(high.risque - low.risque);

      // Vérifier sacrifices opposés
      bool both_sacrifice = (high.sacrifice && low.sacrifice);

      string result = "";

      if(!phase_ok)
         result += "⚠️ INCOHÉRENT: Phases incompatibles | ";
      else
         result += "✅ COHÉRENT: Phases compatibles | ";

      if(delta_risk >= 3)
         result += "⚠️ Δ Risque=" + IntegerToString(delta_risk) + " (élevé) | ";
      else
         result += "✓ Δ Risque=" + IntegerToString(delta_risk) + " | ";

      if(both_sacrifice)
         result += "🔴 Double sacrifice";
      else if(high.sacrifice || low.sacrifice)
         result += "🟠 Sacrifice détecté";
      else
         result += "🟢 Pas de sacrifice";

      return result;
   }

   // Recommandation selon position prix
   string GetRecommendation(double current, double high, double low)
   {
      double range = high - low;
      if(range <= 0) return "⚠️ Range invalide";

      double position = (current - low) / range * 100.0;

      if(position >= 80)
         return "🔴 VENDRE - Prix proche HIGH (" + DoubleToString(position, 1) + "%)";
      else if(position >= 60)
         return "🟠 PRUDENCE - Zone haute (" + DoubleToString(position, 1) + "%)";
      else if(position >= 40)
         return "🟢 NEUTRE - Milieu range (" + DoubleToString(position, 1) + "%)";
      else if(position >= 20)
         return "🟠 ATTENTION - Zone basse (" + DoubleToString(position, 1) + "%)";
      else
         return "🔵 ACHETER - Prix proche LOW (" + DoubleToString(position, 1) + "%)";
   }

   // Vérifier si sacrifice
   bool IsSacrificeStrategy(const ChessStrategy &strat)
   {
      return strat.sacrifice;
   }

   // Vérifier si partie célèbre
   bool IsCelebreStrategy(const ChessStrategy &strat)
   {
      return strat.celebre;
   }

   // Obtenir stratégie par ID case
   ChessStrategy GetStrategyByCase(string case_id)
   {
      for(int i = 0; i < 64; i++)
      {
         if(strategies[i].case_id == case_id)
            return strategies[i];
      }

      ChessStrategy empty;
      empty.case_id = "";
      empty.nom = "";
      empty.phase = "";
      empty.risque = 0;
      empty.complexite = 0;
      empty.principe = "";
      empty.sacrifice = false;
      empty.celebre = false;
      return empty;
   }
};
//+------------------------------------------------------------------+

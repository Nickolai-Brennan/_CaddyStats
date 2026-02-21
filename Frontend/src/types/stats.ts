// Golf stats TypeScript types
// Populated in Phase 3+ (stats schema alignment)

export interface Golfer {
  id: string;
  name: string;
  country?: string;
  owgrRank?: number;
}

export interface Tournament {
  id: string;
  name: string;
  seasonYear: number;
  startDate: string;
  endDate: string;
}

export interface Projection {
  golferId: string;
  tournamentId: string;
  projScore?: number;
  winProb?: number;
  top10Prob?: number;
  makeCutProb?: number;
  edgeScore?: number;
}

export interface BettingOdds {
  golferId: string;
  tournamentId: string;
  book: string;
  market: string;
  odds: number;
  impliedProb: number;
}

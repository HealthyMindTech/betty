const ChessWebAPI = require('chess-web-api');
const cheerio = require('cheerio');
const axios = require('axios');

const chessAPI = new ChessWebAPI({queue: true});

async function getPlayer(playerName)  {
  return await chessAPI.getPlayer(playerName);
}

async function printPlayer(playerName) {
  var player = await getPlayer(playerName);
  console.log(player.body);
}

async function getPlayerTournaments(playerName) {
  var player = await chessAPI.getPlayerTournaments(playerName);
  console.log(player.body);
}

async function printTournament(tournamentId) {
  try { 
  } catch (e) {
    return null;
  }

}

async function lookupTournament(tournamentId) {
  const tournament = await chessAPI.getTournament(tournamentId);
  return tournament.body;
}

async function lookupTournamentRounds(tournamentId, round) {
  const tournamentRounds = await chessAPI.getTournamentRoundGroup(tournamentId, round);
  return tournamentRounds.body;
}

async function* getNewTournaments() {
  const resp = await axios.get("https://www.chess.com/tournament/live/arena?&page=1");
  const $ = cheerio.load(resp.data);
  const links = $("a.tournaments-live-name");
  for (var i = 0; i < links.length; i++) {
    const link = links[i];
    const href = link.attribs["href"];
    const lastSlash = href.lastIndexOf("/");
    
    yield href.slice(lastSlash + 1);
  }
}

async function* getUpcomingTournaments() {
  const resp = await axios.get("https://www.chess.com/tournament/upcoming/arena?&page=1");
  const $ = cheerio.load(resp.data);
  const rows = $("tr")
  for (var i = 0; i < rows.length; i++) {
    const row = rows[i];
    let tdCount = 0;
    let id, name, date;
    for (var j = 0; j < row.children.length; j++) {
      const child = row.children[j];
      if (child.type !== 'tag' || child.name != 'td') {
        continue;
      }
      if (tdCount === 0) {
        id = $(child).text().trim();
        console.log(id);
      } else if (tdCount === 1) {
        name = $(child).text().trim();
        console.log(name);
      } else if (tdCount === 5) {
        const dateText = $(child).text().trim().replaceAll(/\s+/g, ' ');
        date = new Date(new Date(dateText).toISOString().replace(/Z$/, "-08:00"));
        console.log(date);
      }
      tdCount++;
    }
    if (name != null && id != null && date != null) {
      yield {
        name,
        id,
        date
      }
    }
  }
}

function getTournamentId(tournamentObj) {
  console.log(tournamentObj);
  return `${tournamentObj.name.replaceAll(/\s/g, "-").replaceAll(/[^\w\d_-]/g, "")}-${tournamentObj.id}`;
}

async function getTournaments() {
  for await(const value of getUpcomingTournaments()) {
    console.log(value);
    const tournamentId = getTournamentId(value);
    const res = await lookupTournament(tournamentId);
    console.log(res);
    try {
      const t = await lookupTournamentRounds(value, 1);
      console.log(t);
      return;
    } catch (e) {}
    
  }
}

//lookupTournament('10-bullet-1186229').then(console.log)
//lookupTournamentRounds('10-bullet-1186229', 1).then(console.log)
//printTournament("10-bullet-1186180");




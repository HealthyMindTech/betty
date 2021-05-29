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

async function lookupTournamentRound(tournamentId, round) {
  const tournamentRounds = await chessAPI.getTournamentRound(tournamentId, round);
  return tournamentRounds.body;
}

async function* getNewTournaments() {
  const resp = await axios.get("https://www.chess.com/tournament/live?&page=1");
  const $ = cheerio.load(resp.data);
  const links = $("a.tournaments-live-name");
  for (var i = 0; i < links.length; i++) {
    const link = links[i];
    const href = link.attribs["href"];
    const lastSlash = href.lastIndexOf("/");
    
    yield href.slice(lastSlash + 1);
  }
}

function twoDigits(num) {
  let prefix = "";
  if (num < 0) {
    prefix = "-";
    num = -num;
  }
  
  if (num < 10) {
    return prefix + "0" + num;
  } else {
    return prefix + num;
  }
}

function currentTimezoneOffset() {
  let offset = -2 * 60 - 7 * 60;
  const prefix = offset < 0 ? "-" : "+";
  if (offset < 0) {
    offset = -offset;
  }
  return prefix + twoDigits(Math.floor(offset / 60)) + ":" + twoDigits(offset % 60);
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
      } else if (tdCount === 1) {
        name = $(child).text().trim();
      } else if (tdCount === 5) {
        const dateText = $(child).text().trim().replace(/\s+/g, ' ');
        date = new Date(new Date(dateText).toISOString().replace(/Z$/, "-07:00"));
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
  const res = `${tournamentObj.name.replace(/\s/g, "-").replace(/[^\w\d_-]/g, "")}-${tournamentObj.id}`;
  return res.toLowerCase();
}

exports.getTournamentId = getTournamentId;
exports.getUpcomingTournaments = getUpcomingTournaments;
exports.lookupTournament = lookupTournament;
exports.lookupTournamentRound = lookupTournamentRound;

const ChessWebAPI = require('chess-web-api');
const cheerio = require('cheerio');
const axios = require('axios');

const chessAPI = new ChessWebAPI();

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
    const tournament = await chessAPI.getTournament(tournamentId);
    console.log(tournament.body);
  } catch (e) {
    return null;
  }

}

async function getTournaments() {
  const resp = await axios.get("https://www.chess.com/tournament/live/arena?&page=1");
  const $ = cheerio.load(resp.data);
  const links = $("a.tournaments-live-name");
  const res = [];
  for (var i = 0; i < links.length; i++) {
    const link = links[i];
    const href = link.attribs["href"];
    const lastSlash = href.lastIndexOf("/");
    
    res.push(href.slice(lastSlash + 1));
  }
  return res;
}

const tournaments = getTournaments();
tournaments.then(x => {
  x.forEach(printTournament)
});
    
  //getPlayerTournaments("tniel");
      //printTournament("10-bullet-1186180");




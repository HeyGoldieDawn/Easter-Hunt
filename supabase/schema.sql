-- Easter Hunt — Supabase PostgreSQL Schema
-- Run this in Supabase SQL editor: Database → SQL Editor → New query → paste → Run

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if re-running
DROP TABLE IF EXISTS player_rounds CASCADE;
DROP TABLE IF EXISTS clues CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS question_bank CASCADE;
DROP TABLE IF EXISTS hunts CASCADE;

CREATE TABLE hunts (
  id TEXT PRIMARY KEY DEFAULT encode(gen_random_bytes(3), 'hex'),
  name TEXT NOT NULL,
  mode TEXT NOT NULL DEFAULT 'multi',
  age_group TEXT NOT NULL DEFAULT 'teen',
  total_rounds INTEGER NOT NULL DEFAULT 5,
  topics TEXT NOT NULL DEFAULT '[]',
  status TEXT NOT NULL DEFAULT 'setup',
  join_code TEXT UNIQUE NOT NULL,
  admin_token TEXT NOT NULL,
  started_at BIGINT,
  created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
);

CREATE TABLE players (
  id TEXT PRIMARY KEY DEFAULT encode(gen_random_bytes(4), 'hex'),
  hunt_id TEXT NOT NULL REFERENCES hunts(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  gift TEXT NOT NULL DEFAULT '',
  session_token TEXT UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(16), 'hex'),
  current_round INTEGER NOT NULL DEFAULT 0,
  current_phase TEXT NOT NULL DEFAULT 'waiting',
  finish_rank INTEGER,
  finished_at BIGINT,
  joined_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
);

CREATE TABLE clues (
  id SERIAL PRIMARY KEY,
  hunt_id TEXT NOT NULL REFERENCES hunts(id) ON DELETE CASCADE,
  round_number INTEGER NOT NULL,
  text TEXT NOT NULL
);

CREATE TABLE player_rounds (
  id SERIAL PRIMARY KEY,
  player_id TEXT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  hunt_id TEXT NOT NULL,
  round_number INTEGER NOT NULL,
  question_id INTEGER,
  trivia_answered BOOLEAN NOT NULL DEFAULT FALSE,
  clue_found BOOLEAN NOT NULL DEFAULT FALSE,
  answered_at BIGINT,
  found_at BIGINT
);

CREATE TABLE question_bank (
  id SERIAL PRIMARY KEY,
  qid TEXT UNIQUE NOT NULL,
  topic TEXT NOT NULL,
  audience TEXT NOT NULL DEFAULT 'teen',
  question TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct TEXT NOT NULL
);

-- ─── Movies (25) ────────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_01', 'movies', 'teen', 'In ''The Shawshank Redemption'' (1994), what tool does Andy Dufresne use to slowly tunnel through his cell wall over 19 years?', 'A spoon', 'A chisel', 'A rock hammer', 'A nail file', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_02', 'movies', 'teen', 'Which director made both ''Blade Runner'' (1982) and ''Gladiator'' (2000)?', 'James Cameron', 'Ridley Scott', 'Christopher Nolan', 'Steven Spielberg', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_03', 'movies', 'teen', 'What fictional African country is home to Black Panther''s kingdom in the MCU?', 'Genosha', 'Latveria', 'Sokovia', 'Wakanda', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_04', 'movies', 'teen', 'In ''Interstellar'' (2014), the crew visits several planets after the wormhole. Which do they reach first?', 'Edmunds'' planet', 'Mann''s planet', 'Miller''s planet', 'Saturn''s moon', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_05', 'movies', 'teen', 'Who delivers the line ''You can''t handle the truth!'' in ''A Few Good Men''?', 'Tom Hanks', 'Jack Nicholson', 'Al Pacino', 'Kevin Bacon', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_06', 'movies', 'teen', 'Which film features the line ''Elementary, my dear Watson'' — and is notable for the phrase actually NOT appearing in Arthur Conan Doyle''s original stories?', 'The Hound of the Baskervilles (1939)', 'Sherlock Holmes (2009)', 'Without a Clue (1988)', 'Young Sherlock Holmes (1985)', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_07', 'movies', 'teen', 'The 1994 film ''Forrest Gump'' mentions life is like a box of what?', 'Surprises', 'Chocolates', 'Wishes', 'Puzzles', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_08', 'movies', 'teen', 'What was the name of the island where the dinosaurs lived in the original ''Jurassic Park'' (1993)?', 'Isla Sorna', 'Isla Nublar', 'Isla Muer', 'Isla Cabra', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_09', 'movies', 'teen', 'In ''The Matrix'' (1999), Neo is offered which two pills — one to stay in the simulation, one to see the truth?', 'Red and Blue', 'Black and White', 'Green and Yellow', 'Purple and Orange', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_10', 'movies', 'teen', 'Which animated film features the song ''Let It Go'' and is set in the fictional kingdom of Arendelle?', 'Brave', 'Moana', 'Frozen', 'Tangled', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_11', 'movies', 'teen', 'In ''Fight Club'' (1999), what is the first rule of Fight Club?', 'No weapons', 'No women allowed', 'You do not talk about Fight Club', 'One fight at a time', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_12', 'movies', 'teen', 'Which 1993 film follows an arrogant weatherman doomed to relive the same day over and over?', '12 Monkeys', 'Groundhog Day', 'Memento', 'Edge of Tomorrow', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_13', 'movies', 'teen', 'What spaceship do Han Solo and Chewbacca fly in the Star Wars universe?', 'The Tantive IV', 'The Executor', 'The Millennium Falcon', 'The Ghost', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_14', 'movies', 'teen', 'In ''Parasite'' (2019), where does the Park family keep their safe in the basement?', 'Behind a painting', 'Under the floor', 'Behind a bookshelf', 'Inside a wardrobe', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_15', 'movies', 'teen', 'Which actress played Katniss Everdeen in ''The Hunger Games'' franchise?', 'Shailene Woodley', 'Emma Watson', 'Saoirse Ronan', 'Jennifer Lawrence', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_16', 'movies', 'teen', 'The film ''Everything Everywhere All at Once'' won Best Picture at which Academy Awards ceremony?', '2021 (93rd)', '2022 (94th)', '2023 (95th)', '2024 (96th)', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_17', 'movies', 'teen', 'In ''Back to the Future'', what speed must the DeLorean reach to activate time travel?', '55 mph', '77 mph', '88 mph', '100 mph', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_18', 'movies', 'teen', 'Which director is known for ''Pulp Fiction'', ''Kill Bill'', and ''Once Upon a Time in Hollywood''?', 'David Fincher', 'Quentin Tarantino', 'Joel Coen', 'Paul Thomas Anderson', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_19', 'movies', 'teen', '''Spirited Away'' (2001) is a Japanese animated film directed by whom?', 'Makoto Shinkai', 'Mamoru Hosoda', 'Satoshi Kon', 'Hayao Miyazaki', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_20', 'movies', 'teen', 'In ''The Silence of the Lambs'', what does Hannibal Lecter claim to have eaten with fava beans?', 'A senator''s aide', 'A census taker''s liver', 'A police officer''s heart', 'A nurse''s kidney', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_21', 'movies', 'teen', 'Which film was the first feature-length animated movie ever released by Walt Disney Productions?', 'Bambi', 'Pinocchio', 'Snow White and the Seven Dwarfs', 'Fantasia', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_22', 'movies', 'teen', 'What is the name of the bar in ''Cheers'', the long-running American sitcom later adapted into films?', 'Moe''s Tavern', 'Paddy''s Pub', 'The Regal Beagle', 'Cheers (the bar is named Cheers)', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_23', 'movies', 'teen', 'In ''Arrival'' (2016), what triggers the alien heptapods to leave Earth?', 'Humans decode their weapon and use it', 'Louise reveals the future to the Chinese general', 'The UN votes to attack', 'A nuclear weapon is detonated near their ship', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_24', 'movies', 'teen', 'Which actor played Iron Man / Tony Stark across the Marvel Cinematic Universe films?', 'Chris Evans', 'Mark Ruffalo', 'Robert Downey Jr.', 'Benedict Cumberbatch', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('mov_25', 'movies', 'teen', 'In Kubrick''s ''2001: A Space Odyssey'', what does HAL 9000 refuse to do when astronaut Dave Bowman asks?', 'Plot a return course to Earth', 'Open the pod bay doors', 'Display the mission briefing', 'Wake the crew from hibernation', 'b');

-- ─── Forestry (25) ───────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_01', 'forestry', 'teen', 'What is the process by which trees release water vapour through their leaves called?', 'Photosynthesis', 'Respiration', 'Transpiration', 'Osmosis', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_02', 'forestry', 'teen', 'Which layer of a tree trunk transports water and minerals upward from the roots?', 'Heartwood', 'Bark (phloem)', 'Cambium', 'Xylem (sapwood)', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_03', 'forestry', 'teen', 'The Amazon rainforest spans primarily across which country?', 'Colombia', 'Peru', 'Venezuela', 'Brazil', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_04', 'forestry', 'teen', 'What forestry term describes harvesting ALL trees in an area at once?', 'Selective logging', 'Clear-cutting', 'Coppicing', 'Shelterwood harvesting', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_05', 'forestry', 'teen', 'Underground fungal networks linking forest tree roots are nicknamed what?', 'The root web', 'The mycelium grid', 'The wood wide web', 'The fungal floor', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_06', 'forestry', 'teen', 'Which tree produces acorns as its fruit?', 'Beech', 'Chestnut', 'Oak', 'Elm', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_07', 'forestry', 'teen', 'What is the term for a forest management technique where trees are cut near the ground to encourage regrowth of multiple stems?', 'Pollarding', 'Coppicing', 'Thinning', 'Crown reduction', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_08', 'forestry', 'teen', 'The Daintree Rainforest, one of the world''s oldest tropical rainforests, is located in which country?', 'Papua New Guinea', 'Indonesia', 'New Zealand', 'Australia', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_09', 'forestry', 'teen', 'What is the scientific name for the photosynthesis-absorbing green pigment in leaves?', 'Carotene', 'Chlorophyll', 'Anthocyanin', 'Xanthophyll', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_10', 'forestry', 'teen', 'Which tree holds the record for being the tallest living tree species on Earth?', 'Giant Sequoia', 'Douglas Fir', 'Coast Redwood', 'Sitka Spruce', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_11', 'forestry', 'teen', 'In forest ecology, what term describes a plant that grows on another plant (but doesn''t harm it), like many orchids and ferns?', 'Parasite', 'Epiphyte', 'Saprophyte', 'Lithophyte', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_12', 'forestry', 'teen', 'What percentage of the Earth''s land surface is covered by forests?', 'About 11%', 'About 21%', 'About 31%', 'About 41%', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_13', 'forestry', 'teen', 'The taiga (boreal forest) is the world''s largest land biome. It is predominantly found in which region?', 'Central Africa', 'Northern Russia, Canada, and Scandinavia', 'The Himalayas', 'Southern South America', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_14', 'forestry', 'teen', 'What chemical compound gives autumn leaves their red and purple colours?', 'Chlorophyll', 'Carotene', 'Tannin', 'Anthocyanin', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_15', 'forestry', 'teen', 'Which ancient tree, found in California''s White Mountains, is considered one of the oldest individual living organisms on Earth?', 'A coast redwood', 'A bristlecone pine', 'A giant sequoia', 'A baobab', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_16', 'forestry', 'teen', 'Deforestation contributes to climate change primarily by releasing what gas?', 'Methane', 'Nitrous oxide', 'Carbon dioxide', 'Ozone', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_17', 'forestry', 'teen', 'What is the name of the zone in a forest between the full-canopy forest and open land, known for high biodiversity?', 'The edge effect zone', 'The ecotone', 'The understory', 'The riparian zone', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_18', 'forestry', 'teen', 'The rubber tree (Hevea brasiliensis) is native to which region?', 'Central Africa', 'Southeast Asia', 'The Amazon Basin', 'Central America', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_19', 'forestry', 'teen', 'What is silviculture?', 'The study of silver deposits in forest soil', 'The art and science of growing and cultivating forests', 'The practice of carving wood for art', 'The measurement of tree age using rings', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_20', 'forestry', 'teen', 'Dendrochronology is the scientific method of dating trees and timber by analysing what?', 'Leaf shape', 'Root depth', 'Annual growth rings', 'Bark texture', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_21', 'forestry', 'teen', 'Which tree is known as the ''pioneer species'' because it is often the first to colonise disturbed land after a fire or clearance?', 'Oak', 'Silver birch', 'Yew', 'Beech', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_22', 'forestry', 'teen', 'What does a forest''s ''canopy layer'' refer to?', 'The root network underground', 'The layer of moss and lichens on the forest floor', 'The topmost layer of overlapping tree crowns', 'The mid-level shrub layer', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_23', 'forestry', 'teen', 'The seeds of which tree spin like helicopter rotors and are called ''samaras'' or ''helicopters'' by children?', 'Oak', 'Ash', 'Maple', 'Walnut', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_24', 'forestry', 'teen', 'In forestry, what does ''FSC'' stand for?', 'Federal Silviculture Council', 'Forest Stewardship Council', 'Foundation for Sustainable Cutting', 'Forest Species Catalogue', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('for_25', 'forestry', 'teen', 'Which ancient Japanese practice involves mindful immersion in a forest environment for health benefits?', 'Ikebana', 'Wabi-sabi', 'Shinrin-yoku', 'Kintsugi', 'c');

-- ─── Travel (25) ─────────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_01', 'travel', 'teen', 'The ancient city of Petra, carved into rose-red sandstone cliffs, is located in which country?', 'Saudi Arabia', 'Egypt', 'Jordan', 'Israel', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_02', 'travel', 'teen', 'The Trans-Siberian Railway, the world''s longest, runs from Moscow to which Pacific port city?', 'Irkutsk', 'Novosibirsk', 'Vladivostok', 'Yakutsk', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_03', 'travel', 'teen', 'In which Southeast Asian city would you find the famous street food market of Jalan Alor?', 'Bangkok', 'Kuala Lumpur', 'Singapore', 'Ho Chi Minh City', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_04', 'travel', 'teen', 'The Northern Lights are most reliably visible from which of these destinations?', 'Edinburgh, Scotland', 'Helsinki city centre', 'Tromsø, Norway', 'Copenhagen, Denmark', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_05', 'travel', 'teen', 'Which island chain in Indonesia is home to the Komodo dragon in the wild?', 'Bali', 'The Lesser Sunda Islands (incl. Komodo Island)', 'Borneo', 'Java', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_06', 'travel', 'teen', 'The ancient Incan citadel of Machu Picchu sits at approximately what elevation?', '1,200 m (3,900 ft)', '2,430 m (7,970 ft)', '3,800 m (12,500 ft)', '5,200 m (17,000 ft)', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_07', 'travel', 'teen', 'What is the deepest lake in the world, holding about 20% of the world''s unfrozen fresh water?', 'Lake Superior', 'Lake Titicaca', 'Caspian Sea', 'Lake Baikal', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_08', 'travel', 'teen', 'The Camino de Santiago is a famous pilgrimage route ending in which city?', 'Pamplona', 'Santiago de Compostela', 'Seville', 'Lisbon', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_09', 'travel', 'teen', 'Which country has the most UNESCO World Heritage Sites?', 'France', 'India', 'China', 'Italy', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_10', 'travel', 'teen', 'The Serengeti National Park, famous for the Great Migration of wildebeest, is located in which country?', 'Kenya', 'South Africa', 'Tanzania', 'Botswana', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_11', 'travel', 'teen', 'What is the name of the iconic long-distance hiking trail running the length of New Zealand''s South Island?', 'Te Araroa Trail', 'The Routeburn Track', 'The Milford Track', 'The Heaphy Track', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_12', 'travel', 'teen', 'The Maldives is known for being the world''s lowest-lying country. What threat does this pose?', 'Volcanic eruption risk', 'Submersion due to rising sea levels', 'Desert expansion', 'Permafrost collapse', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_13', 'travel', 'teen', 'Which country has more natural lakes than any other in the world?', 'Russia', 'Finland', 'Canada', 'Norway', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_14', 'travel', 'teen', 'The Blue Mosque (Sultan Ahmed Mosque) is a landmark in which city?', 'Tehran', 'Cairo', 'Istanbul', 'Dubai', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_15', 'travel', 'teen', 'Angkor Wat, the world''s largest religious monument, is located in which country?', 'Vietnam', 'Thailand', 'Myanmar', 'Cambodia', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_16', 'travel', 'teen', 'Which city is divided by the famous Bosphorus strait, straddling two continents?', 'Athens', 'Istanbul', 'Alexandria', 'Tbilisi', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_17', 'travel', 'teen', 'The Amalfi Coast, a famous scenic drive, is located in which Italian region?', 'Tuscany', 'Sicily', 'Sardinia', 'Campania', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_18', 'travel', 'teen', 'What is the name of the world''s largest coral reef system?', 'The Mesoamerican Barrier Reef', 'The Great Barrier Reef', 'The New Caledonia Barrier Reef', 'The Andros Barrier Reef', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_19', 'travel', 'teen', 'Reykjavik is the capital of Iceland. Approximately how many people live in all of Iceland?', 'About 150,000', 'About 370,000', 'About 700,000', 'About 1.2 million', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_20', 'travel', 'teen', 'The Inca Trail trek culminates at which ancient site?', 'Cusco', 'Chan Chan', 'Machu Picchu', 'Chichen Itza', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_21', 'travel', 'teen', 'Which ocean would you cross when flying non-stop from London to New York?', 'The Arctic Ocean', 'The North Atlantic Ocean', 'The Pacific Ocean', 'The North Sea', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_22', 'travel', 'teen', 'The Hagia Sophia, originally a cathedral then a mosque and now a mosque again, is in which city?', 'Athens', 'Rome', 'Jerusalem', 'Istanbul', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_23', 'travel', 'teen', 'Patagonia, a popular destination for hiking and wilderness travel, spans parts of which two countries?', 'Brazil and Uruguay', 'Chile and Argentina', 'Bolivia and Peru', 'Colombia and Ecuador', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_24', 'travel', 'teen', 'The famous Silk Road historically connected China to which region?', 'West Africa', 'The Mediterranean and Europe', 'The Indian subcontinent only', 'Japan and Korea', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('trv_25', 'travel', 'teen', 'Which country is made up of 17,508 islands, making it the world''s largest archipelago nation?', 'Philippines', 'Japan', 'Indonesia', 'Malaysia', 'c');

-- ─── Geography (25) ──────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_01', 'geography', 'teen', 'What is the only country in the world that borders both the Atlantic and Indian Oceans?', 'Brazil', 'Angola', 'South Africa', 'Mozambique', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_02', 'geography', 'teen', 'The Mariana Trench — the deepest point on Earth — is in which ocean?', 'Atlantic', 'Indian', 'Arctic', 'Pacific', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_03', 'geography', 'teen', 'Which river flows through the most countries?', 'The Nile', 'The Amazon', 'The Danube', 'The Congo', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_04', 'geography', 'teen', 'What percentage of the Earth''s surface is covered by water?', '51%', '61%', '71%', '81%', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_05', 'geography', 'teen', 'Mount Kilimanjaro is the highest peak on which continent?', 'South America', 'Asia', 'Australia', 'Africa', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_06', 'geography', 'teen', 'What is the largest desert on Earth (by area)?', 'The Gobi Desert', 'The Sahara Desert', 'The Antarctic Desert', 'The Arabian Desert', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_07', 'geography', 'teen', 'The Ring of Fire, a zone of frequent earthquakes and volcanic eruptions, encircles which ocean?', 'The Atlantic', 'The Indian', 'The Pacific', 'The Arctic', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_08', 'geography', 'teen', 'Which is the world''s longest river?', 'The Amazon', 'The Nile', 'The Yangtze', 'The Mississippi', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_09', 'geography', 'teen', 'What is the capital of Australia?', 'Sydney', 'Melbourne', 'Perth', 'Canberra', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_10', 'geography', 'teen', 'Which country has the world''s longest coastline?', 'Russia', 'Australia', 'Norway', 'Canada', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_11', 'geography', 'teen', 'The Sahara Desert spans approximately how many African countries?', '5', '8', '11', '14', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_12', 'geography', 'teen', 'Which two continents does the Ural mountain range traditionally separate?', 'Asia and Africa', 'Europe and Asia', 'Europe and North America', 'North Asia and South Asia', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_13', 'geography', 'teen', 'The Dead Sea, the world''s lowest point on land, borders which countries?', 'Israel, Jordan, and the Palestinian West Bank', 'Egypt and Israel', 'Syria and Lebanon', 'Jordan and Saudi Arabia', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_14', 'geography', 'teen', 'Which country is entirely landlocked within South Africa?', 'Swaziland (Eswatini)', 'Lesotho', 'Both Swaziland and Lesotho', 'Zimbabwe', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_15', 'geography', 'teen', 'The Caspian Sea is technically a lake. Which country has the longest coastline along it?', 'Russia', 'Kazakhstan', 'Iran', 'Azerbaijan', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_16', 'geography', 'teen', 'Which is the world''s smallest country by land area?', 'Monaco', 'San Marino', 'Liechtenstein', 'Vatican City', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_17', 'geography', 'teen', 'The Great Rift Valley, a massive geological formation, runs through which continent?', 'Asia', 'Australia', 'Africa', 'South America', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_18', 'geography', 'teen', 'Which South American country has the most Spanish speakers?', 'Argentina', 'Colombia', 'Mexico (in North America)', 'Colombia', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_19', 'geography', 'teen', 'What is the name of the narrow strip of land connecting North and South America?', 'The Yucatán Isthmus', 'The Isthmus of Panama', 'The Darien Gap', 'The Central American Bridge', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_20', 'geography', 'teen', 'Lake Titicaca, the highest navigable lake in the world, straddles the border of which two countries?', 'Peru and Ecuador', 'Bolivia and Chile', 'Peru and Bolivia', 'Argentina and Chile', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_21', 'geography', 'teen', 'Which ocean is the smallest of the world''s five oceans?', 'Indian', 'Southern', 'Arctic', 'Atlantic', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_22', 'geography', 'teen', 'The Cape of Good Hope is at the southern tip of which country?', 'Namibia', 'Angola', 'South Africa', 'Mozambique', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_23', 'geography', 'teen', 'Greenland is the world''s largest island. It is a territory of which country?', 'Norway', 'Iceland', 'Canada', 'Denmark', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_24', 'geography', 'teen', 'The Amazon River discharges into which ocean?', 'The Pacific', 'The Caribbean Sea', 'The Atlantic', 'The Gulf of Mexico', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('geo_25', 'geography', 'teen', 'Which mountain range includes the Himalaya, Karakoram, Hindu Kush, and Pamir ranges collectively?', 'The Asian Highlands', 'The Trans-Himalayan Ranges', 'The Hindu-Kush System', 'The Greater Himalayas', 'b');

-- ─── Philosophy (25) ─────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_01', 'philosophy', 'teen', 'Plato''s ''Allegory of the Cave'' — describing prisoners who mistake shadows for reality — appears in which work?', 'The Apology', 'Phaedo', 'The Republic', 'The Symposium', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_02', 'philosophy', 'teen', 'Which philosopher wrote ''Cogito, ergo sum'' (''I think, therefore I am'')?', 'Immanuel Kant', 'René Descartes', 'John Locke', 'David Hume', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_03', 'philosophy', 'teen', 'Which philosopher introduced the ''categorical imperative'' as a universal principle of morality?', 'John Stuart Mill', 'Friedrich Nietzsche', 'Jeremy Bentham', 'Immanuel Kant', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_04', 'philosophy', 'teen', '''The unexamined life is not worth living'' is attributed to which philosopher?', 'Aristotle', 'Epicurus', 'Socrates', 'Plato', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_05', 'philosophy', 'teen', 'The philosophical thought experiment ''Trolley Problem'' explores which ethical concept?', 'Virtue ethics', 'Moral dilemmas and consequentialism vs deontology', 'Social contract theory', 'Existentialism', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_06', 'philosophy', 'teen', 'Jean-Paul Sartre''s existentialist phrase ''existence precedes essence'' means what?', 'Physical existence is more important than spiritual matters', 'Humans define their own meaning rather than having a preset purpose', 'Life has no meaning at all', 'Essence of things precedes their physical existence', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_07', 'philosophy', 'teen', 'Which ancient Greek philosopher was Plato''s teacher and Aristotle''s teacher''s teacher?', 'Thales', 'Heraclitus', 'Socrates', 'Pythagoras', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_08', 'philosophy', 'teen', 'What is ''Occam''s Razor''?', 'The idea that the most complex explanation is usually correct', 'The principle that entities should not be multiplied beyond necessity (prefer the simplest explanation)', 'The view that truth can only be known through religious texts', 'A logical fallacy involving ad hominem attacks', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_09', 'philosophy', 'teen', 'Which philosopher wrote ''Thus Spoke Zarathustra'' and introduced the concept of the Übermensch?', 'Arthur Schopenhauer', 'Georg Hegel', 'Friedrich Nietzsche', 'Martin Heidegger', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_10', 'philosophy', 'teen', 'Utilitarianism, the idea that the right action maximises overall happiness, is most associated with which philosophers?', 'Kant and Hegel', 'Bentham and Mill', 'Locke and Rousseau', 'Aristotle and Plato', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_11', 'philosophy', 'teen', 'The ''Ship of Theseus'' paradox explores which philosophical question?', 'The existence of God', 'Personal identity and persistence through change', 'Free will vs determinism', 'The nature of time', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_12', 'philosophy', 'teen', 'Which philosopher described the ''state of nature'' as ''nasty, brutish, and short'' — arguing humans need a social contract?', 'Jean-Jacques Rousseau', 'John Locke', 'Thomas Hobbes', 'David Hume', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_13', 'philosophy', 'teen', 'In Plato''s philosophy, what are the ''Forms'' or ''Ideas''?', 'The physical objects we see around us', 'Perfect abstract archetypes of which physical things are imperfect copies', 'Gods who govern the universe', 'Mathematical equations underlying reality', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_14', 'philosophy', 'teen', 'Albert Camus described the absurd as the conflict between what?', 'Good and evil', 'Humans'' search for meaning and the universe''s silence/indifference', 'Free will and fate', 'Mind and body', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_15', 'philosophy', 'teen', 'What is ''solipsism''?', 'The belief that everything is made of one substance', 'The view that only one''s own mind is certain to exist', 'The denial of free will', 'The belief that God created the universe but doesn''t intervene', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_16', 'philosophy', 'teen', '''I know that I know nothing'' is a paraphrase associated with which philosopher?', 'Plato', 'Aristotle', 'Socrates', 'Diogenes', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_17', 'philosophy', 'teen', 'John Rawls'' ''veil of ignorance'' thought experiment is a device for designing what?', 'A perfect military strategy', 'A fair and just society without knowing your place in it', 'An optimal economic market', 'A system of environmental laws', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_18', 'philosophy', 'teen', 'Epistemology is the branch of philosophy concerned with what?', 'Ethics and morality', 'The nature of beauty', 'The nature and scope of knowledge', 'The existence of God', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_19', 'philosophy', 'teen', 'Which philosopher argued that ''God is dead'' — meaning that the Enlightenment had destroyed the foundations of traditional morality?', 'Karl Marx', 'Søren Kierkegaard', 'Friedrich Nietzsche', 'Bertrand Russell', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_20', 'philosophy', 'teen', 'The ''Chinese Room'' thought experiment was designed by John Searle to argue what?', 'That Chinese philosophy is superior to Western philosophy', 'That syntax (symbol manipulation) alone cannot produce genuine understanding or consciousness', 'That machines can have feelings', 'That language determines thought', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_21', 'philosophy', 'teen', 'Stoicism, founded by Zeno of Citium, teaches that human happiness comes from what?', 'Pleasure and the avoidance of pain', 'Wealth and social status', 'Virtue and control over one''s own judgements and reactions', 'Total detachment from all desires', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_22', 'philosophy', 'teen', 'What does Aristotle''s ''Golden Mean'' refer to?', 'The ideal monetary system', 'The virtue found between two extremes (deficiency and excess)', 'A mathematical ratio found in nature', 'The perfect balance of the four humours', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_23', 'philosophy', 'teen', 'Which 20th-century philosopher wrote ''Being and Time'' (Sein und Zeit)?', 'Jean-Paul Sartre', 'Edmund Husserl', 'Martin Heidegger', 'Ludwig Wittgenstein', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_24', 'philosophy', 'teen', 'The Socratic Method involves reaching truth through what process?', 'Quiet meditation and personal reflection', 'Reading ancient texts carefully', 'Collaborative questioning and dialogue that exposes contradictions', 'Mathematical proof and logic alone', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('phi_25', 'philosophy', 'teen', 'Simone de Beauvoir''s ''The Second Sex'' is a foundational text in which movement?', 'Existentialism only', 'Feminist philosophy and theory', 'Marxist theory', 'Phenomenology', 'b');

-- ─── Animals (20) ────────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_01', 'animals', 'child', 'What do you call a baby dog?', 'A kitten', 'A puppy', 'A foal', 'A cub', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_02', 'animals', 'child', 'Which animal is known for its black and white stripes?', 'A giraffe', 'A tiger', 'A zebra', 'A leopard', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_03', 'animals', 'child', 'What sound does a cow make?', 'Moo', 'Baa', 'Oink', 'Cluck', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_04', 'animals', 'child', 'Which animal is the tallest in the world?', 'An elephant', 'A giraffe', 'A horse', 'A polar bear', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_05', 'animals', 'child', 'Where do penguins live in the wild?', 'The North Pole', 'The Amazon rainforest', 'The Antarctic and Southern Ocean', 'The Sahara desert', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_06', 'animals', 'child', 'What do caterpillars turn into?', 'Beetles', 'Butterflies or moths', 'Dragonflies', 'Bees', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_07', 'animals', 'child', 'Which animal has a pouch to carry its baby?', 'A rabbit', 'A kangaroo', 'A deer', 'A wolf', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_08', 'animals', 'child', 'How many legs does a spider have?', '6', '10', '4', '8', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_09', 'animals', 'child', 'Which animal is famous for changing its colour to blend in?', 'A crocodile', 'A chameleon', 'A frog', 'A lizard', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_10', 'animals', 'child', 'What is the fastest land animal?', 'A lion', 'A horse', 'A cheetah', 'An ostrich', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_11', 'animals', 'child', 'Which bird cannot fly?', 'A parrot', 'A sparrow', 'An ostrich', 'An eagle', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_12', 'animals', 'child', 'What do bees make?', 'Silk', 'Honey', 'Wax only', 'Milk', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_13', 'animals', 'child', 'Which animal is the largest on Earth?', 'The African elephant', 'The great white shark', 'The blue whale', 'The giraffe', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_14', 'animals', 'child', 'What do you call a baby cat?', 'A cub', 'A pup', 'A kitten', 'A lamb', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_15', 'animals', 'child', 'Which animal builds a dam to make a pond to live in?', 'An otter', 'A beaver', 'A mole', 'A platypus', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_16', 'animals', 'child', 'What colour is a flamingo?', 'White', 'Yellow', 'Pink', 'Blue', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_17', 'animals', 'child', 'Which animal has a very long nose called a trunk?', 'A rhinoceros', 'A tapir', 'A hippopotamus', 'An elephant', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_18', 'animals', 'child', 'A group of lions is called a…', 'Pack', 'Herd', 'Pride', 'Flock', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_19', 'animals', 'child', 'Which of these animals sleeps through winter (hibernates)?', 'A rabbit', 'A bear', 'A cat', 'A horse', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('ani_20', 'animals', 'child', 'Where do fish breathe using?', 'Their nose', 'Their skin', 'Their gills', 'Their fins', 'c');

-- ─── Nature (20) ─────────────────────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_01', 'nature', 'child', 'What colours appear in a rainbow? Pick the correct list.', 'Red, orange, yellow, green, blue, indigo, violet', 'Red, pink, yellow, green, blue, purple, brown', 'Red, orange, yellow, green, teal, blue, purple', 'Red, yellow, green, blue, white, grey, black', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_02', 'nature', 'child', 'In which season do most trees lose their leaves?', 'Spring', 'Summer', 'Autumn', 'Winter', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_03', 'nature', 'child', 'What does a seed need to start growing?', 'Sunlight and salt', 'Water, warmth, and soil (or compost)', 'Ice and wind', 'Sand and moonlight', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_04', 'nature', 'child', 'What is the centre of our solar system?', 'The Moon', 'The Earth', 'Jupiter', 'The Sun', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_05', 'nature', 'child', 'What colour do leaves turn to make food from sunlight?', 'Red', 'Brown', 'Green (because of chlorophyll)', 'Yellow', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_06', 'nature', 'child', 'What is rain water called before it falls — when it is up in the sky?', 'Fog', 'A cloud', 'Dew', 'Mist', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_07', 'nature', 'child', 'How many planets are in our solar system?', '7', '8', '9', '10', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_08', 'nature', 'child', 'What is frozen water called?', 'Steam', 'Ice', 'Frost only', 'Hail only', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_09', 'nature', 'child', 'Which season comes after winter?', 'Autumn', 'Summer', 'Spring', 'Another winter', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_10', 'nature', 'child', 'What do we call the part of a flower that is brightly coloured to attract bees?', 'The stem', 'The root', 'The petal', 'The leaf', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_11', 'nature', 'child', 'What is the name of our planet?', 'Mars', 'Venus', 'Jupiter', 'Earth', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_12', 'nature', 'child', 'What shape is a snowflake?', 'Round', 'Six-sided (hexagonal)', 'Square', 'Triangle', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_13', 'nature', 'child', 'What do plants use sunlight to make?', 'Water', 'Soil', 'Food (through photosynthesis)', 'Oxygen only', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_14', 'nature', 'child', 'Which colour is made by mixing red and blue?', 'Orange', 'Green', 'Yellow', 'Purple', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_15', 'nature', 'child', 'What falls from the sky in a thunderstorm?', 'Snow', 'Hail or rain', 'Mud', 'Leaves', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_16', 'nature', 'child', 'A caterpillar wraps itself in a silk case to transform. What is that case called?', 'A shell', 'A cocoon or chrysalis', 'A nest', 'A pod', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_17', 'nature', 'child', 'Which is hotter — the Sun or the Moon?', 'They are both the same temperature', 'The Moon', 'The Sun', 'It depends on the season', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_18', 'nature', 'child', 'What do you call the sound thunder makes during a storm?', 'A clap or rumble of thunder', 'Lightning crack', 'A sky boom', 'A cloud burst', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_19', 'nature', 'child', 'What colour is the sky on a clear sunny day?', 'White', 'Grey', 'Blue', 'Purple', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('nat_20', 'nature', 'child', 'What do you call the natural home where an animal lives?', 'A garden', 'A habitat', 'A territory', 'A burrow (for every animal)', 'b');

-- ─── Fairy Tales & Stories (20) ──────────────────────────────────────────────
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_01', 'fairytales', 'child', 'In ''Goldilocks and the Three Bears'', whose porridge was ''just right''?', 'Daddy Bear''s', 'Mummy Bear''s', 'Baby Bear''s', 'Goldilocks made her own', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_02', 'fairytales', 'child', 'What does Cinderella leave behind at the ball when she runs away at midnight?', 'Her handbag', 'Her glass slipper', 'Her tiara', 'Her glove', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_03', 'fairytales', 'child', 'In ''Jack and the Beanstalk'', what does Jack trade for magic beans?', 'His bicycle', 'His shoes', 'The family cow', 'A golden egg', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_04', 'fairytales', 'child', 'What is the name of the fairy in ''Peter Pan''?', 'Pixie', 'Tinker Bell', 'Rosebud', 'Glitter', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_05', 'fairytales', 'child', 'In ''Snow White'', what does the Evil Queen ask her magic mirror every day?', 'How to make a potion', 'Who is the fairest of them all?', 'Where is Snow White hiding?', 'How to find the dwarfs', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_06', 'fairytales', 'child', 'How many dwarfs does Snow White live with?', 'Five', 'Six', 'Eight', 'Seven', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_07', 'fairytales', 'child', 'In ''The Three Little Pigs'', what does the wolf huff and puff to try to do?', 'Make it rain', 'Blow the houses down', 'Scare the pigs away', 'Climb over the fence', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_08', 'fairytales', 'child', 'In ''Sleeping Beauty'', what makes the princess fall into a deep sleep?', 'A poisoned apple', 'A magic mirror', 'A spinning wheel''s spindle prick', 'A witch''s spell involving a flower', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_09', 'fairytales', 'child', 'What is Pinocchio famous for?', 'His red hat', 'His nose growing when he tells a lie', 'His magic wand', 'His dancing shoes', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_10', 'fairytales', 'child', 'In ''Hansel and Gretel'', what is the witch''s house made of?', 'Straw', 'Bricks', 'Gingerbread and sweets', 'Wood and leaves', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_11', 'fairytales', 'child', 'In ''The Ugly Duckling'', what does the ugly duckling grow up to become?', 'A beautiful swan', 'A proud peacock', 'A colourful parrot', 'A graceful flamingo', 'a');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_12', 'fairytales', 'child', 'What does Rumpelstiltskin want in exchange for spinning straw into gold?', 'The queen''s crown', 'Her ring', 'Her firstborn child', 'A bag of gold coins', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_13', 'fairytales', 'child', 'In ''Little Red Riding Hood'', who is disguised as Grandma in bed?', 'A fox', 'A bear', 'The woodsman', 'The Big Bad Wolf', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_14', 'fairytales', 'child', 'Aladdin finds a magic lamp in a cave. What comes out when he rubs the lamp?', 'A fairy godmother', 'A dragon', 'A genie', 'A princess', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_15', 'fairytales', 'child', 'In the original fairy tale, The Little Mermaid wants to live on land. What does she give up to get legs?', 'Her tail', 'Her beautiful voice', 'Her memories', 'Her best friend', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_16', 'fairytales', 'child', 'What breaks the spell on the Beast in ''Beauty and the Beast''?', 'A magic potion', 'A kiss from the prince', 'True love — Belle says she loves him', 'The enchanted rose fully blooming', 'c');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_17', 'fairytales', 'child', 'In ''Puss in Boots'', the cat helps his owner seem rich and powerful. What gift did the owner receive from his father?', 'A horse', 'A bag of money', 'A magical sword', 'A cat (Puss)', 'd');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_18', 'fairytales', 'child', 'Alice falls into Wonderland by following which animal down a rabbit hole?', 'A white cat', 'A white rabbit with a pocket watch', 'A talking mouse', 'A blue caterpillar', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_19', 'fairytales', 'child', 'In ''The Wizard of Oz'', Dorothy wants to go home. What does she tap together to get there?', 'Her blue shoes', 'Her silver shoes (ruby slippers in the film)', 'Her hands', 'A magic wand', 'b');
INSERT INTO question_bank (qid, topic, audience, question, option_a, option_b, option_c, option_d, correct) VALUES
('fts_20', 'fairytales', 'child', 'In ''Rapunzel'', how does the prince (or witch) climb up to the tower?', 'Using a magic ladder', 'By climbing a vine', 'By climbing Rapunzel''s long hair', 'Using a magic carpet', 'c');

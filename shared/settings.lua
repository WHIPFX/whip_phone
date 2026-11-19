-- The Phone page in /whip -> Settings: config.lua's values an owner changes most, edited in game. Each key is a
-- path in Config: config.lua's value is the default, a saved value is written into Config on both sides, and the
-- code goes on reading Config.X (whip_core's Whip.configPage, docs.html#registersettings).
--
-- LIVE unless a row says otherwise: every value here is read when it is used (a dial reads ServiceNumbers and
-- RingSeconds, a new SIM reads NumberPrefixes), so a change is in force at once. The keys and the phone's size and
-- clock reach a player's game when it loads the phone: those rows say so.

Whip.configPage({
    label = 'Phone',
    groups = {
        { label = 'Service numbers', settings = {
            { key = 'ServiceNumbers', type = 'map', label = 'Service numbers',
              help = 'Short numbers anyone can dial (911, 311). Each rings every on-duty member of its jobs who carries a phone; the first to answer takes the call.',
              keyLabel = 'Number', keyPattern = '^%d%d%d?%d?%d?%d?$', keyWhy = 'must be 2 to 6 digits', maxItems = 20,
              fields = {
                  { key = 'label', type = 'string', label = 'Label', maxLen = 40,
                    help = 'What the answerer\'s call screen shows over the caller\'s number' },
                  { key = 'jobs', type = 'list', label = 'Jobs that answer', minItems = 1, maxItems = 20,
                    help = 'Job keys from /whip -> Jobs, comma separated (police, ems)',
                    item = { type = 'string', maxLen = 50, pattern = '^[%w_%-]+$', patternWhy = 'is not a job key' } },
                  { key = 'shareLocation', type = 'bool', label = 'Share caller location',
                    help = 'The answerer\'s GPS is set to where the caller dialled from' },
                  { key = 'noAnswer', type = 'string', label = 'No answer message', maxLen = 80,
                    help = 'What the caller hears when nobody is on duty, everyone declines, or it rings out' },
              } },
        } },
        { label = 'Calls', settings = {
            { key = 'RingSeconds', type = 'int', min = 10, max = 120, unit = 's', label = 'Ring time',
              help = 'How long an unanswered call rings before it is missed' },
            { key = 'RecentCalls', type = 'int', min = 10, max = 200, label = 'Recent calls shown' },
            { key = 'MessageHistory', type = 'int', min = 50, max = 1000, label = 'Messages loaded per conversation' },
            { key = 'SpeakerRange', type = 'number', min = 1, max = 30, step = 1, unit = 'm', label = 'Speakerphone range',
              help = 'How far a phone on speaker carries' },
            { key = 'VoiceDownText', type = 'string', maxLen = 120, label = 'No voice system message',
              help = 'Shown over every phone while no voice resource is running' },
        } },
        { label = 'Numbers', settings = {
            { key = 'NumberPrefixes', type = 'list', minItems = 1, maxItems = 20, label = 'New number prefixes',
              help = 'A new number is one of these 3 digits, then 7 random ones. Numbers already given out keep theirs.',
              item = { type = 'string', maxLen = 3, pattern = '^%d%d%d$', patternWhy = 'must be 3 digits' } },
        } },
        { label = 'Phone', settings = {
            { key = 'OpenKey', type = 'string', maxLen = 20, label = 'Open key', apply = 'restart',
              why = 'A new default only reaches players who have not bound the key themselves' },
            { key = 'AnswerKey', type = 'string', maxLen = 20, label = 'Answer key', apply = 'restart',
              why = 'A new default only reaches players who have not bound the key themselves' },
            { key = 'DeclineKey', type = 'string', maxLen = 20, label = 'Decline key', apply = 'restart',
              why = 'A new default only reaches players who have not bound the key themselves' },
            { key = 'PhoneSize', type = 'number', min = 0.3, max = 0.8, step = 0.05, label = 'Phone size',
              apply = 'restart', why = 'Players see it when the phone next loads',
              help = 'The folded phone\'s height, as a share of the screen' },
            { key = 'GameClock', type = 'bool', label = 'In-game time on the clock', apply = 'restart',
              why = 'Players see it when the phone next loads',
              help = 'Off: the player\'s real clock' },
            { key = 'SkillGameNoPhone', type = 'string', maxLen = 80, label = 'No phone message',
              help = 'Said when a skill check game needs a phone the player does not have' },
        } },
    },
})

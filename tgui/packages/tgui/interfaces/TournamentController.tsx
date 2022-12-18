import { useBackend, useLocalState } from '../backend';
import { Button, Dropdown, Section, Stack } from '../components';
import { Window } from '../layouts';

type TournamentControllerData = {
  old_mobs: number;
  arena_id: string;
  arena_templates: string[];
  team_names: string[];
};

const ArenaInfo = (props, context) => {
  const { act, data } = useBackend<TournamentControllerData>(context);

  const [selectedArena, setSelectedArea] = useLocalState<string | null>(
    context,
    'selectedArena',
    null
  );

  return (
    <Section
      title={
        <Stack>
          <Stack.Item
            grow={1}
            style={{
              'overflow': 'hidden',
              'white-space': 'nowrap',
              'text-overflow': 'ellipsis',
            }}>
            {'Arena - ' + data.arena_id}
          </Stack.Item>
          <Stack.Item align="end" shrink={0}>
            <Button
              color="transparent"
              icon="info"
              tooltip="This interface DOES NOT cache your selections, so it is best to leave it open the entire time you are running an arena."
              tooltipPosition="bottom-start"
            />
          </Stack.Item>
        </Stack>
      }>
      <Stack fill>
        <Stack.Item grow>
          <Dropdown
            width="100%"
            selected={selectedArena ?? 'Select a map...'}
            options={data.arena_templates}
            onSelected={setSelectedArea}
          />
        </Stack.Item>

        <Stack.Item>
          <Button
            color="green"
            icon="map"
            onClick={() =>
              act('load_arena', {
                arena_template: selectedArena,
              })
            }>
            Load
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RoundInfo = (props, context) => {
  const { act, data } = useBackend<TournamentControllerData>(context);

  const [selectedTeamA, setSelectedTeamA] = useLocalState(
    context,
    'selectedTeamA',
    data.team_names[0]
  );

  const [selectedTeamB, setSelectedTeamB] = useLocalState(
    context,
    'selectedTeamB',
    data.team_names[1]
  );

  const [respawnRemove, setRespawnRemove] = useLocalState(
    context,
    'respawnRemove',
    true
  );

  return (
    <>
      <Section title="Round">
        <Stack fill>
          <Stack.Item grow>
            <Dropdown
              width="100%"
              selected={selectedTeamA}
              options={data.team_names}
              onSelected={setSelectedTeamA}
            />
          </Stack.Item>

          <Stack.Item>
            <b>VS.</b>
          </Stack.Item>

          <Stack.Item grow>
            <Dropdown
              width="100%"
              selected={selectedTeamB}
              options={data.team_names}
              onSelected={setSelectedTeamB}
            />
          </Stack.Item>

          <Stack.Item>
            <Button
              icon="user-edit"
              onClick={() => {
                act('vv_teams');
              }}>
              VV teams
            </Button>
          </Stack.Item>
        </Stack>
        <Stack vertical mt={2}>
          <Stack.Item>
            <Button.Checkbox
              checked={respawnRemove}
              onClick={() => setRespawnRemove(!respawnRemove)}
              tooltip="Delete existing fighters?"
            />{' '}
            <Button.Confirm
              content="Spawn teams"
              color="green"
              icon="user-friends"
              onClick={() => {
                act('spawn_teams', {
                  team_a: selectedTeamA,
                  team_b: selectedTeamB,
                  clear: respawnRemove,
                });
              }}
              tooltip="Respawn before loading maps for the best participant experience."
            />
          </Stack.Item>

          <Stack.Item>
            <Button.Confirm
              content="Start countdown"
              icon="stopwatch"
              onClick={() => act('start_countdown')}
              tooltip="This will open the shutters at the end of the countdown."
            />
          </Stack.Item>

          <Stack.Item>
            <Button icon="door-closed" onClick={() => act('close_shutters')}>
              Close one way <i>shutters</i>
            </Button>
          </Stack.Item>

          <Stack.Item>
            <Button icon="door-open" onClick={() => act('open_shutters')}>
              Open one way <i>shutters</i>
            </Button>
          </Stack.Item>

          <Stack.Item>
            <Button.Confirm
              content="Disband teams"
              color="red"
              icon="user-minus"
              onClick={() => act('disband_teams')}
              tooltip="This will put team members back into their spectator mobs (if they had one)."
            />{' '}
            {data.old_mobs} spectator mobs stored
          </Stack.Item>

          <Stack.Item>
            <Button.Confirm
              content="Clear arena"
              color="red"
              icon="recycle"
              onClick={() => act('clear_arena')}
              tooltip="You don't have to do this if you're already loading a new map, by the way."
            />
            <br />
            Clear automaticly happens on map load, and does not delete teams in
            prep rooms.
          </Stack.Item>

          <Stack.Item>
            <Button
              content="Export team data"
              color="green"
              icon="file-arrow-down"
              onClick={() => act('export_teams')}
              tooltip="Download the current teams' JSON data including outfits."
            />
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Copy Pasta Zone">
        {selectedTeamA} VS. {selectedTeamB}
        <br />
        <br />
        {selectedTeamA}
        <br />
        VS.
        <br />
        {selectedTeamB}
      </Section>
    </>
  );
};

export const TournamentController = () => {
  return (
    <Window width={600} height={532} theme="admin">
      <Window.Content scrollable>
        <ArenaInfo />
        <RoundInfo />
      </Window.Content>
    </Window>
  );
};

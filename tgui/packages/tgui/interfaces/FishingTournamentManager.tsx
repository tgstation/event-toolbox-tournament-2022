import { useBackend } from '../backend';
import { Button, LabeledList, TimeDisplay, NumberInput } from '../components';
import { Window } from '../layouts';

type FishingTournamentManagerData = {
  tournament: string;
  tournament_going_on: boolean;
  time_left: number;
  duration: number;
  rods_given: boolean;
};

export const FishingTournamentManager = (props, context) => {
  const { act, data } = useBackend<FishingTournamentManagerData>(context);
  const { tournament, tournament_going_on, time_left, duration, rods_given } = data;

  return (
    <Window title="Fishing Tournament Manager Panel" width={330} height={160}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Button onClick={() => act('open_or_create')}>
              {tournament || 'Create new'}
            </Button>
            {!!tournament && (
              <>
              <Button onClick={() => act('open_VV')}>
                VV
              </Button>
              {!!tournament_going_on && (
                <LabeledList.Item label="Time left">
                  <TimeDisplay value={time_left} auto="down" />
                </LabeledList.Item>
              )}
              </>
            )}
          </LabeledList.Item>
          {!!tournament && (
            <>
            {!tournament_going_on && (
              <LabeledList.Item label="Tournament Duration">
                <NumberInput
                  width="100px"
                  value={duration / 10}
                  unit="s"
                  minValue={0}
                  maxValue={900}
                  onChange={(e, value) =>
                    act('set_duration', {
                      duration: value * 10,
                    })
                  }
                />
              </LabeledList.Item>
              )}
              <LabeledList.Item label="Actions">
                  <Button onClick={() => act('get')}>Get</Button>
                  {!tournament_going_on && (
                    <Button
                      content='Start Tournament'
                      color={rods_given ? 'green' : 'yellow'}
                      onClick={() => act('start')}
                    />
                  )}
                  <Button
                    content='Give rods'
                    color={rods_given ? 'yellow' : 'green'}
                    icon={rods_given ? 'check-square-o' : 'square-o'}
                    onClick={() => act('give_rods')}
                  />
                  {!!tournament_going_on && (
                    <Button
                      content='Stop Tournament Now'
                      color='orange'
                      onClick={() => act('stop')}
                    />
                  )}
                  <Button
                    content='Delete'
                    color='red'
                    onClick={() => act('delete')}
                  />
              </LabeledList.Item>
            </>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};

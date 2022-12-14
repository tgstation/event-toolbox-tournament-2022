import { useBackend } from '../backend';
import { Button, LabeledList, TimeDisplay, NumberInput } from '../components';
import { Window } from '../layouts';

type FishingTournamentManagerData = {
  tournament: string;
  tournament_going_on: boolean;
  time_left: number;
  duration: number;
};

export const FishingTournamentManager = (props, context) => {
  const { act, data } = useBackend<FishingTournamentManagerData>(context);
  const { tournament, tournament_going_on, time_left, duration } = data;

  return (
    <Window>
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
                  value={duration}
                  unit="ds"
                  minValue={0}
                  onChange={(e, value) =>
                    act('set_duration', {
                      duration: value,
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
                      color='green'
                      onClick={() => act('start')}
                    />
                  )}
                  {!!tournament_going_on && (
                    <Button
                      content='Stop Tournament Now'
                      color='yellow'
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

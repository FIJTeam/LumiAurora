import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Box, BlockQuote, Button, LabeledList, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export type SMESData = {
  name_tag: string;
  charge_taken: number;
  charging: BooleanLike;
  charge_attempt: BooleanLike;
  charge_level: number;
  charge_max: number;
  output_load: number;
  outputting: BooleanLike;
  output_attempt: BooleanLike;
  output_level: number;
  output_max: number;
  time: number;
  wtime: number;
  charge_mode: number;
  stored_capacity: number;
  fail_time: number;
};

export const SMES = (props, context) => {
  const { act, data } = useBackend<SMESData>(context);

  return (
    <Window resizable theme="hephaestus" width={420} height={330}>
      <Window.Content scrollable>
        {data.fail_time ? <FailWindow /> : <SMESWindow />}
      </Window.Content>
    </Window>
  );
};

export const FailWindow = (props, context) => {
  const { act, data } = useBackend<SMESData>(context);

  return (
    <Section
      title="SYSTEM FAILURE"
      buttons={
        <Button
          content="Reboot Now"
          icon="sync"
          color="bad"
          onClick={() => act('reboot')}
        />
      }>
      <Box>I/O regulator malfuction detected! Waiting for system reboot...</Box>
      <BlockQuote>Automatic reboot in {data.fail_time} seconds...</BlockQuote>
    </Section>
  );
};

export const SMESWindow = (props, context) => {
  const { act, data } = useBackend<SMESData>(context);

  return (
    <>
      <Section title="Supermagnetic Storage">
        <LabeledList>
          <LabeledList.Item label="Stored Capacity">
            <ProgressBar
              color={data.charging ? 'good' : 'average'}
              value={data.stored_capacity}
              minValue={0}
              maxValue={100}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Charge Status">
            {data.charge_mode === 1
              ? `Charge will complete in ${time_remaining(
                data.time,
                data.wtime
              )}.`
              : data.charge_mode === 2
                ? 'Output and input balanced.'
                : `Charge will run out in ${time_remaining(
                  data.time,
                  data.wtime
                )}.`}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Input Management"
        buttons={[
          <Button
            key="inputButton"
            content={data.charge_attempt ? 'Auto' : 'Off'}
            color={data.charge_attempt ? 'good' : 'bad'}
            icon={data.charge_attempt ? 'sync' : 'times'}
            onClick={() => act('cmode')}
          />,
        ]}>
        <LabeledList>
          <LabeledList.Item label="Charge Mode">
            <Box as="span" color={charge_class(data.charge_mode)}>
              [{charge_status(data.charge_mode)}]
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Input Level">
            <Slider
              value={data.charge_level}
              fillValue={data.charge_taken}
              minValue={0}
              maxValue={data.charge_max}
              step={5000}
              stepPixelSize={4}
              unit="W"
              onDrag={(e, value) =>
                act('input', {
                  input: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Output Management"
        buttons={[
          <Button
            key="outputButton"
            content={data.output_attempt ? 'Online' : 'Offline'}
            color={data.output_attempt ? 'good' : 'bad'}
            icon={data.output_attempt ? 'power-off' : 'times'}
            onClick={() => act('online')}
          />,
        ]}>
        <LabeledList>
          <LabeledList.Item label="Output Status">
            <Box as="span" color={output_class(data.outputting)}>
              [{output_status(data.outputting)}]
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Output Level">
            <Slider
              value={data.output_level}
              fillValue={data.output_load}
              minValue={0}
              maxValue={data.output_max}
              step={5000}
              stepPixelSize={4}
              unit="W"
              onDrag={(e, value) =>
                act('output', {
                  output: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};

const time_remaining = (time, wtime) => {
  let timeleft = (time - wtime) / 10; // deciseconds
  let hours = Math.round(timeleft / 3600);
  let minutes = Math.round((timeleft % 3600) / 60);
  let seconds = Math.round(timeleft % 60);
  return [
    hours >= 1 && `${hours} hours`,
    minutes >= 1 && `${minutes} minutes`,
    seconds >= 1 && `${seconds} seconds`,
  ]
    .filter(Boolean)
    .join(', ');
};

const charge_class = (charge_mode) => {
  switch (charge_mode) {
    case 2:
      return 'good';
    case 1:
      return 'average';
    default:
      return 'bad';
  }
};

const charge_status = (charge_mode) => {
  switch (charge_mode) {
    case 2:
      return 'Charging';
    case 1:
      return 'Partially Charging';
    default:
      return 'Not Charging';
  }
};

const output_class = (value) => {
  switch (value) {
    case 2:
      return 'good';
    case 1:
      return 'average';
    default:
      return 'bad';
  }
};

const output_status = (value) => {
  switch (value) {
    case 2:
      return 'Outputting';
    case 1:
      return 'Disconnected or No Charge';
    default:
      return 'Not Outputting';
  }
};

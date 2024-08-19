import { BooleanLike } from 'common/react';
import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section, Table } from '../components';

type AtmosMixerData = {
  power: BooleanLike;
  configuring: BooleanLike;
  power_draw: number;
  max_power_draw: number;
  ports: Port[];
  flow_rate: number;
  max_flow_rate: number;
  current_flow_rate: number;
};

type Port = {
  dir: string;
  concentration: number;
  input: BooleanLike;
  output: BooleanLike;
  lock: BooleanLike;
};

export const AtmosMixer = (props, context) => {
  const { act, data } = useBackend<AtmosMixerData>(context);
  const {
    power,
    configuring,
    max_flow_rate,
    flow_rate,
    current_flow_rate,
    power_draw,
    max_power_draw,
    ports,
  } = data;

  return (
    <Window width={470} height={330}>
      <Window.Content>
        <Section
          title="Gas Mixer"
          buttons={[
            <Button
              icon={power ? 'power-off' : 'times'}
              key={'button1'}
              content={power ? 'On' : 'Off'}
              selected={power}
              disabled={configuring}
              onClick={() => act('power')}
            />,
            <Button
              icon="wrench"
              key={'button2'}
              selected={configuring}
              onClick={() => act('configure')}
            />,
          ]}>
          <LabeledList>
            <LabeledList.Item label="Flow Rate">
              {flow_rate ? (
                configuring ? (
                  <>
                    <NumberInput
                      animated
                      value={flow_rate}
                      width="63px"
                      unit="L/s"
                      minValue={0}
                      maxValue={max_flow_rate}
                      onChange={(_, value) =>
                        act('set_flow_rate', {
                          rate: value,
                        })
                      }
                    />
                    <Button
                      icon="plus"
                      content="Max"
                      disabled={flow_rate === max_flow_rate}
                      onClick={() =>
                        act('set_flow_rate', { rate: max_flow_rate })
                      }
                    />
                  </>
                ) : (
                  flow_rate + ' L/s'
                )
              ) : (
                'No Output port!'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Current Flow Rate">
              <ProgressBar
                animated
                color={(() => {
                  if (current_flow_rate > (flow_rate / 3) * 2) {
                    return 'green';
                  } else if (current_flow_rate > flow_rate / 3) {
                    return 'yellow';
                  } else {
                    return 'red';
                  }
                })()}
                minValue={0}
                maxValue={flow_rate}
                value={current_flow_rate}>
                {current_flow_rate} L/s
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Load">
              <ProgressBar
                animated
                color={(() => {
                  if (power_draw > (max_power_draw / 3) * 2) {
                    return 'red';
                  } else if (power_draw > max_power_draw / 3) {
                    return 'yellow';
                  } else {
                    return 'green';
                  }
                })()}
                minValue={0}
                maxValue={max_power_draw}
                value={power_draw}>
                {power_draw} W
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {ports && ports.length && (
          <Section title="Settings">
            <Table>
              <Table.Row header>
                <Table.Cell>Port</Table.Cell>
                {configuring ? (
                  <>
                    <Table.Cell>Input</Table.Cell>
                    <Table.Cell>Output</Table.Cell>
                  </>
                ) : (
                  <Table.Cell>Mode</Table.Cell>
                )}
                <Table.Cell>Concentration</Table.Cell>
                {configuring === 1 && <Table.Cell>Lock</Table.Cell>}
              </Table.Row>
              {ports.map((port) => (
                <Table.Row key={port.dir}>
                  <Table.Cell>{port.dir} Port</Table.Cell>
                  {configuring ? (
                    <>
                      <Table.Cell>
                        <Button
                          icon={port.input ? 'power-off' : 'times'}
                          content={port.input ? 'On' : 'Off'}
                          selected={port.input}
                          disabled={port.output}
                          onClick={() => {
                            if (port.input) {
                              act('switch_mode', {
                                mode: 'none',
                                dir: port.dir,
                              });
                            } else {
                              act('switch_mode', {
                                mode: 'in',
                                dir: port.dir,
                              });
                            }
                          }}
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          icon={port.output ? 'power-off' : 'times'}
                          content={port.output ? 'On' : 'Off'}
                          selected={port.output}
                          onClick={() => {
                            if (!port.output) {
                              act('switch_mode', {
                                mode: 'out',
                                dir: port.dir,
                              });
                            }
                          }}
                        />
                      </Table.Cell>
                    </>
                  ) : (
                    <Table.Cell>
                      {port.input === 1 && 'Input'}
                      {port.output === 1 && 'Output'}
                    </Table.Cell>
                  )}
                  <Table.Cell>
                    {port.input ? (
                      configuring ? (
                        port.lock ? (
                          port.concentration + ' %'
                        ) : (
                          <NumberInput
                            animated
                            value={port.concentration}
                            width="63px"
                            unit="%"
                            minValue={0}
                            maxValue={100}
                            onChange={(_, value) =>
                              act('set_concentration', {
                                dir: port.dir,
                                concentration: value,
                              })
                            }
                          />
                        )
                      ) : (
                        port.concentration + ' %'
                      )
                    ) : (
                      <Button content="None" disabled />
                    )}
                  </Table.Cell>
                  {configuring === 1 && (
                    <Table.Cell>
                      <Button
                        icon={port.lock ? 'lock' : 'unlock'}
                        content={port.lock ? 'Locked' : 'Unlocked'}
                        selected={port.lock}
                        disabled={!port.input}
                        onClick={() => act('switch_lock', { dir: port.dir })}
                      />
                    </Table.Cell>
                  )}
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

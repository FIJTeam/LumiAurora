import { useBackend, useLocalState } from '../backend';
import { Section, LabeledList, NoticeBox, ProgressBar, Button } from '../components';
import { capitalize } from '../../common/string';

export type AtmosData = {
  sensors: Sensor[];
  maxrate: number;
  maxpressure: number;
};

type Sensor = {
  id_tag: string;
  name: string;
  datapoints: Datapoint[];
};

type Datapoint = {
  datapoint: string;
  data: string;
  unit: string;
};

export const AtmosControl = (props, context) => {
  const { act, data } = useBackend<AtmosData>(context);
  return data.sensors.length ? (
    <SensorData />
  ) : (
    <NoticeBox>No sensors connected.</NoticeBox>
  );
};

export const SensorData = (props, context) => {
  const { act, data } = useBackend<AtmosData>(context);
  const [showAllGases, setShowAllGases] = useLocalState(
    context,
    'showAlGases',
    false
  );
  return (
    <>
      {data.sensors.map((sensor) => (
        <>
          <Section title={sensor.name} key={sensor.id_tag}>
            <LabeledList>
              {sensor.datapoints.map((datapoint) =>
                datapoint.data !== null && datapoint.unit !== '%' ? (
                  <LabeledList.Item
                    key={datapoint.datapoint}
                    label={capitalize(datapoint.datapoint)}>
                    {datapoint.data} {datapoint.unit}
                  </LabeledList.Item>
                ) : (
                  ''
                )
              )}
            </LabeledList>
          </Section>

          <Section
            title={sensor.name + ' Gases'}
            buttons={[
              <Button
                key="showAllGasesButton"
                content="Show All Gases"
                icon="book"
                selected={showAllGases}
                onClick={() => setShowAllGases(!showAllGases)}
              />,
            ]}>
            <LabeledList>
              {sensor.datapoints.map((datapoint) =>
                datapoint.data !== null &&
                datapoint.unit === '%' &&
                (showAllGases || Number.parseFloat(datapoint.data) !== 0) ? (
                  <LabeledList.Item
                    key={datapoint.datapoint}
                    label={getGasNameByDatapoint(datapoint)}>
                    <ProgressBar
                      value={Number.parseFloat(datapoint.data)}
                      minValue={0}
                      maxValue={100}
                      color={getColorByGasName(datapoint.datapoint)}>
                      {datapoint.data} {datapoint.unit}
                    </ProgressBar>
                  </LabeledList.Item>
                ) : (
                  ''
                )
              )}
            </LabeledList>
          </Section>
        </>
      ))}
    </>
  );
};

const getColorByGasName = (gasName: string) => {
  switch (gasName) {
    case 'oxygen':
      return 'blue';
    case 'nitrogen':
      return 'crimson';
    case 'phoron':
      return '#FF8C00';
    case 'hydrogen':
      return 'indigo';
    case 'carbon_dioxide':
      return 'gray';
    case 'sleeping_agent':
      return 'yellow';
    case 'helium':
      return '#6B8E23';
    case 'deuterium':
      return;
    case 'tritium':
      return '#B22222';
    case 'boron':
      return 'silver';
    case 'sulfur_dioxide':
      return '#9ACD32';
    case 'nitrogen_dioxide':
      return 'salmon';
    case 'chlorine':
      return '#00FF7F';
    case 'water':
      return 'mediumblue';
    default:
      return 'white';
  }
};

const getGasNameByDatapoint = (gasDatapoint: Datapoint) => {
  let result = '';
  let gasNameList = gasDatapoint.datapoint.replace('_', ' ').split(' ');
  for (let gasNamePart of gasNameList) {
    result += ' ' + capitalize(gasNamePart);
  }
  return result;
};

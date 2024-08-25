import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, NoticeBox, ProgressBar, Section, Table } from '../components';
import { Window } from '../layouts';

type Data = {
  has_lathe: BooleanLike;
  has_imprinter: BooleanLike;
  has_destroy: BooleanLike;
  tech_list: Technology[];
  lathe_materials: MaterialInfo;
  imprinter_materials: MaterialInfo;
};

type Technology = {
  name: string;
  level: number;
  progress: number;
  threshold: number;
};

type MaterialInfo = {
  total: number;
  max_material: number;
  reagents: Material[];
  materials: Material[];
};

type Material = {
  name: string;
  amount: number;
};

const ResearchMenuButton = (props: { content: string; icon: string }) => {
  const { content, icon } = props;
  return (
    <Box>
      <Button mb={1} icon={icon} content={content} />
    </Box>
  );
};

export const ResearchConsole = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { tech_list, has_destroy, has_imprinter, has_lathe } = data;
  const { lathe_materials, imprinter_materials } = data;
  return (
    <Window width={1000} height={800}>
      <Window.Content>
        <Table>
          <Table.Cell>
            <Section title="R&D Console Menu">
              <ResearchMenuButton icon="star" content="Research" />
              <ResearchMenuButton
                icon="cog"
                content="Protolathe Construction Menu"
              />
              <ResearchMenuButton
                icon="network-wired"
                content="Circuit Imprinter Construction Menu"
              />
            </Section>
            <Section title="Destructive Analyzer">
              {has_destroy ? (
                <NoticeBox>No item in Destructive Analyzer</NoticeBox>
              ) : (
                <NoticeBox>Destructive Analyzer is not connected!</NoticeBox>
              )}
            </Section>
            <Section
              title="Settings"
              buttons={[
                <Button icon="lock" content="Lock Console" key="lockConsole" />,
                <Button
                  icon="trash"
                  content="Reset R&D Database"
                  key="resetDB"
                  color="bad"
                />,
              ]}>
              <ResearchMenuButton
                icon="sync"
                content="Sync Database with Network"
              />
              <ResearchMenuButton
                icon="link"
                content="Connect to Research Network"
              />
              <ResearchMenuButton
                icon="ban"
                content="Disconnect from Research Network"
              />
            </Section>
            <Section title="Disk Operations">
              <NoticeBox>No disk inserted!</NoticeBox>
            </Section>
            <Section title="Device Linkage Menu">
              <ResearchMenuButton
                icon="sync"
                content="Re-sync with Nearby Devices"
              />
              <ResearchMenuButton
                icon="times"
                content="Disconnect Destructive Analyzer"
              />
              <ResearchMenuButton
                icon="times"
                content="Disconnect Protolathe"
              />
              <ResearchMenuButton
                icon="times"
                content="Disconnect Circuit Imprinter"
              />
            </Section>
          </Table.Cell>
          <Table.Cell>
            <Section
              title="Technology Research"
              buttons={[
                <Button key="printTech" icon="print" content="Print" />,
              ]}>
              <LabeledList>
                {tech_list.map(
                  (tech, index) =>
                    tech.level !== 0 && (
                      <LabeledList.Item key={'tech' + index} label={tech.name}>
                        <ProgressBar
                          minValue={0}
                          maxValue={8}
                          value={tech.level}
                          ranges={{
                            good: [75, 100],
                            average: [30, 75],
                            bad: [0, 30],
                          }}>
                          <Flex justify="space-between">
                            {tech.level}
                            <span>
                              ({tech.progress}/{tech.threshold})
                            </span>
                          </Flex>
                        </ProgressBar>
                      </LabeledList.Item>
                    )
                )}
              </LabeledList>
            </Section>
            <Section title="Protolathe Material Storage">
              {has_lathe ? (
                <MaterialInformation info={lathe_materials} />
              ) : (
                <NoticeBox>Protholate is not connected!</NoticeBox>
              )}
            </Section>
            <Section title="Circuit Imprinter Material Storage">
              {has_imprinter ? (
                <MaterialInformation info={imprinter_materials} />
              ) : (
                <NoticeBox>Circuit Imprinter is not connected!</NoticeBox>
              )}
            </Section>
          </Table.Cell>
        </Table>
      </Window.Content>
    </Window>
  );
};

const MaterialInformation = (props: { info: MaterialInfo }, context) => {
  const { total, max_material, reagents, materials } = props.info;
  return (
    <Box>
      <ProgressBar
        mb={1}
        minValue={0}
        maxValue={max_material}
        value={total}
        ranges={{
          bad: [(max_material / 4) * 3, max_material],
          average: [max_material / 3, (max_material / 4) * 3],
          good: [0, max_material / 3],
        }}>
        {total}/{max_material}
      </ProgressBar>
      <LabeledList>
        {reagents.map((reagent, index) => (
          <LabeledList.Item
            textAlign="right"
            key={'reagentInfo' + index}
            label={reagent.name}>
            <span>{reagent.amount}</span>
            <Button ml={1} content="Purge" icon="trash" color="bad" />
          </LabeledList.Item>
        ))}
        {materials.map((reagent, index) => (
          <LabeledList.Item
            textAlign="right"
            key={'reagentInfo' + index}
            label={reagent.name}>
            <span>{reagent.amount}</span>
            {reagent.amount > 0 && (
              <Button ml={1} content="Eject" icon="eject" />
            )}
            {reagent.amount > 5 && <Button content="5x" />}
            {reagent.amount > 10 && <Button content="10x" />}
            {reagent.amount > 20 && <Button content="20x" />}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Box>
  );
};

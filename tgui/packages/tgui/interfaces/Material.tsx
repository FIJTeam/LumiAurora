import { clamp } from '../../common/math';
import { capitalize } from '../../common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Input, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  name: string;
  amount: number;
  items: CraftableItem[];
};

type CraftableItem = {
  name: string;
  ref: string;
  sublist_ref: string;
  time_to_craft: number;
  req_amount: number;
};

export const Material = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [searchValue, setSearchValue] = useLocalState<string>(
    context,
    'searchValue',
    ''
  );

  const filteredRecipes = getSearchedItems(data.items, searchValue);
  const height: number = clamp(
    94 + Object.keys(data.items).length * 26,
    250,
    500
  );

  return (
    <Window width={400} height={height}>
      <Window.Content>
        <Section
          title={'Amount: ' + data.amount}
          buttons={[
            <Input
              key="search"
              placeholder="Search"
              onInput={(e, v) => setSearchValue(v)}
            />,
          ]}>
          {filteredRecipes.length ? (
            filteredRecipes.map((item, index) => {
              return (
                <Button
                  mb={1}
                  icon="wrench"
                  width="100%"
                  key={'button' + index}
                  disabled={data.amount / item.req_amount < 1}
                  content={
                    capitalize(item.name) + ' (' + item.req_amount + ' sheets)'
                  }
                  onClick={() =>
                    act('make', { ref: item.ref, sublist: item.sublist_ref })
                  }
                />
              );
            })
          ) : (
            <NoticeBox content="No recipes found!" />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const getSearchedItems = (items: CraftableItem[], searchValue: string) => {
  if (!searchValue || searchValue === '') return items;
  let result: CraftableItem[] = [];
  for (let item of items) {
    if (item.name.toLowerCase().includes(searchValue.toLowerCase())) {
      result.push(item);
    }
  }
  return result;
};

import { signal, useSignal } from "@preact/signals";
import { Intro } from "../../components/Intro";
import { pageConfig } from "../../server/Page.gen";

const counter = signal(0);

export default function DockerReg() {
  const counter2 = useSignal(0);

  return (
    <>
      <Intro>
        Here are two counters, both are made with signals. One is a signal
        defined outside of this component. One signal is defined inside this
        component. By defining the signal a single line higher, you get the
        option to keep state. But, is this a good thing or a bad thing?
      </Intro>
      <p className="py-2">
        Here is the counter that is defined outside of the component. Its state
        will stay the same when you navigate to other pages: {counter}
        <button onClick={() => (counter.value = counter.value + 1)}>+</button>
      </p>
      <p className="py-2">
        Here is the counter that is defined inside the component. Its state will
        reset when you navigate to other pages: {counter2}
        <button onClick={() => (counter2.value = counter2.value + 1)}>+</button>
      </p>
      <p className="py-2">
        This is not possible using React hooks, but it can also lead to bad
        spaghetti code when overused. It also feels a lot more like magic.
      </p>
    </>
  );
}

export const config: pageConfig = {
  title: "Two counters",
};

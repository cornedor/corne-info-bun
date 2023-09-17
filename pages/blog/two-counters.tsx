import { signal, useSignal } from "@preact/signals";
import { Intro } from "../../components/Intro";
import { BaseLayout } from "../../layouts/BaseLayout";
import { PageConfig } from "../../utils/renderPage";

const counter = signal(0);

export default function DockerReg() {
  const counter2 = useSignal(0);

  return (
    <>
      <Intro>
        Here are two counters, both are made with signals. One is a signal
        defined outside of this component. One signal is defined inside this
        component.
      </Intro>
      <p>
        Here is the counter that is defined outside of the component, it state
        will stay the same when you navigate to other pages: {counter}
        <button onClick={() => (counter.value = counter.value + 1)}>+</button>
      </p>
      <p>
        Here is the counter that is defined inside the component, it state will
        reset when you navigate to other pages: {counter2}
        <button onClick={() => (counter2.value = counter2.value + 1)}>+</button>
      </p>
    </>
  );
}

export const config: PageConfig = {
  title: "Two counters",
};

import { useEffect } from "preact/hooks";

interface DevModeProps {
  socket: WebSocket;
}

export function DevMode({ socket }: DevModeProps) {
  console.trace("DevMode");
  const reload = () => {
    socket.send(JSON.stringify({ e: "rebuild" }));
    setTimeout(() => {
      document.location.reload();
    }, 20);
  };

  const handleKeyPress = (e: KeyboardEvent) => {
    if (e.key === "E") {
      reload();
    }
  };

  useEffect(() => {
    window.addEventListener("keypress", handleKeyPress);
    return () => window.addEventListener("keypress", handleKeyPress);
  }, []);

  return (
    <div class="fixed bottom-5 right-6">
      <span class="bg-pink-400 px-2 py-1 rounded-l font-sans">DevMode</span>
      <button
        onClick={reload}
        class="bg-pink-600 hover:underline px-2 py-1 rounded shadow-sm  hover:shadow active:bg-pink-400 text-white focus:ring font-sans"
      >
        Rebuild
      </button>
    </div>
  );
}

globalThis.CLIENTSIDE = globalThis.CLIENTSIDE ?? false;

const db = CLIENTSIDE
  ? null
  : new (await import("bun:sqlite")).Database(":memory:");

if (!CLIENTSIDE) {
  db!
    .query(
      `CREATE TABLE cache (path TEXT PRIMARY KEY, data TEXT, age INTEGER);`
    )
    .run();
}

export const getCachedPageProps = CLIENTSIDE
  ? undefined
  : (path: string) => {
      const query = db!.query<{ data: string; age: number }, { $path: string }>(
        `SELECT data, age FROM cache WHERE path = $path`
      );
      const result = query.all({
        $path: path,
      });

      return result?.[0]
        ? {
            data: result[0].data,
            age: result[0].age,
          }
        : undefined;
    };

export const setCachedPageProps = CLIENTSIDE
  ? undefined
  : (path: string, data: string, age: number) => {
      console.log("Set");
      const query = db!.query<
        undefined,
        { $path: string; $data: string; $age: number }
      >(
        `INSERT OR REPLACE INTO cache (path, data, age) VALUES ($path, $data, $age)`
      );

      query.run({
        $path: path,
        $data: data,
        $age: age,
      });
    };

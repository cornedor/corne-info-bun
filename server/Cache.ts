import { Database } from "bun:sqlite";

const db = new Database(":memory:");

const createDbQuery = db.query(
  `CREATE TABLE cache (path TEXT PRIMARY KEY, data TEXT, age INTEGER);`
);
createDbQuery.run();

export function getCachedPageProps(path: string, age: number) {
  console.log(age);
  const query = db.query<{ data: string; age: number }, { $path: string }>(
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
}

export function setCachedPageProps(path: string, data: string, age: number) {
  console.log("Set");
  const query = db.query<
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
}

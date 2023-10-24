let getAccount = (status: PleromaAPI.pleromaStatus) =>
  switch Js.Nullable.toOption(status.reblog) {
  | Some(reblog) => reblog.account
  | None => status.account
  }

let getIcon = (status: PleromaAPI.pleromaStatus): Icon.iconIds =>
  switch status.visibility {
  | #public => #globe
  | #list => #globe
  | #local => #globe
  | #unlisted => #unlock
  | #"private" => #lock
  | #direct => #envelope
  }

let getMediaLink = (status: PleromaAPI.pleromaMedia) =>
  switch (Js.Nullable.toOption(status.text_url), Js.Nullable.toOption(status.remote_url)) {
  | (Some(url), _) => url
  | (None, Some(url)) => url
  | _ => "#"
  }

let formatDate = date => {
  let dateTime = Js.Date.toTimeString(date)
  let formatter = Intl.DateTimeFormat.makeWithLocaleAndOptions(
    "en-US",
    {
      "dateStyle": "full",
    },
  )
  let formattedDate = Intl.DateTimeFormat.format(formatter, date)

  (dateTime, formattedDate)
}

external parseFediverseJson: option<Js.Json.t> => PleromaAPI.pleromaStatuses = "%identity"
let make: Page.makeFn = props => {
  let pageProps = props["pageProps"]

  let data = parseFediverseJson(pageProps)

  switch Js.Nullable.toOption(data) {
  | Some(statuses) => {
      let statusElems = Belt.Array.map(statuses, status => {
        let account = getAccount(status)
        let (reblog, content, media) = switch Js.Nullable.toOption(status.reblog) {
        | Some(reblog) => (
            <span className="text-green-500 text-sm flex gap-2 items-center md:float-right">
              {React.string("reblogged")}
              <Icon id=#repeat />
            </span>,
            reblog.content,
            reblog.media_attachments,
          )
        | None => (<> </>, status.content, status.media_attachments)
        }

        let (dateTime, formattedDate) = formatDate(Js.Date.fromString(status.created_at))
        let media = Belt.Array.map(media, item =>
          switch item.\"type" {
          | #image =>
            <Link href={getMediaLink(item)} key={item.id}>
              <img
                className="rounded border-2 border-stone-300 object-cover aspect-[9/6]"
                src={item.preview_url}
                width="200"
                height="200"
                loading=#"lazy"
                alt={switch Js.Nullable.toOption(item.description) {
                | Some(str) => str
                | _ => ""
                }}
              />
            </Link>
          | #video =>
            <video
              className="fedi_statusMediaVideo"
              src={getMediaLink(item)}
              controls=true
              key={item.id}
              alt={switch Js.Nullable.toOption(item.description) {
              | Some(str) => str
              | _ => ""
              }}
            />
          | #unknown => <> </>
          | #audio => <> </>
          }
        )

        let content =
          <>
            <div className="fedi_content" dangerouslySetInnerHTML={{"__html": content}} />
            <div className="fedi_content mt-3 flex flex-wrap gap-3"> {React.array(media)} </div>
          </>

        <div
          className="shadow-md p-5 rounded mb-5 border border-stone-300 bg-stone-50 flex flex-row gap-5"
          key={status.id}>
          <div className="fedi_statusAvatar">
            <img
              src={account.avatar}
              width="100"
              height="100"
              className=" max-w-none rounded fedi_avatar"
              loading=#"lazy"
            />
          </div>
          <div className="flex-1">
            <div className="fedi_status-info">
              <Link href={account.url} className="hover:underline">
                <strong> {React.string(account.display_name)} </strong>
                <small> {React.string(" @" ++ account.acct)} </small>
              </Link>
              reblog
              <div className="flex gap-5 text-stone-400 text-xs subtleText">
                {switch Js.Nullable.toOption(status.url) {
                | Some(url) =>
                  <Link href={url} className="hover:underline">
                    <time dateTime> {React.string(formattedDate)} </time>
                  </Link>
                | _ =>
                  <time dateTime className="hover:underline"> {React.string(formattedDate)} </time>
                }}
                <span
                  ariaLabel={"Visibility: " ++ (status.visibility :> string)}
                  title={"Visibility: " ++ (status.visibility :> string)}
                  className="flex gap-2 items-center">
                  <Icon id={getIcon(status)} />
                </span>
                <span ariaLabel="Replies" title="Replies" className="flex gap-2 items-center">
                  <Icon id=#cornerUpLeft />
                  {React.string(Belt.Int.toString(status.replies_count))}
                </span>
                <span ariaLabel="Reblogs" title="Reblogs" className="flex gap-2 items-center">
                  <Icon id=#repeat />
                  {React.string(Belt.Int.toString(status.reblogs_count))}
                </span>
              </div>
            </div>
            {switch Js.Nullable.toOption(status.spoiler_text) {
            | Some(str) if Js.String2.length(str) > 1 =>
              <Spoiler
                summaryContent={<>
                  <strong> {React.string("Spoiler: ")} </strong>
                  {React.string(str)}
                </>}>
                content
              </Spoiler>
            | _ => content
            }}
          </div>
        </div>
      })

      <div className="fedi">
        // <Next.Head>
        //   <meta name="robots" value="noindex, nofollow" />
        // </Next.Head>
        <p className="py-2"> {React.string("Well hello there,")} </p>
        <p className="py-2">
          {React.string(
            "You found my Fediverse page. This is nother special really, it is just a overview of my more recent posts on my Pleroma instance. You can also follow me on your Mastodon or other Fediverse connected service at @corne@cd0.nl",
          )}
        </p>
        <p className="py-2"> {React.string("Thanks, and see you later.")} </p>
        <div className="my-10"> {React.array(statusElems)} </div>
      </div>
    }

  | None => <p> {React.string("Could not fetch my latest statuses in the Fediverse")} </p>
  }
}

let title = "Fediverse"
let config: Page.pageConfig = %raw(`CLIENTSIDE`)
  ? {
      title: title,
    }
  : {
      title,
      // For Mastodon user IDs are required, Pleroma can handle user IDs or user handles.
      // PleromaAPI.fetchStatuses("mastodon.social", "1")->Promise.then(result => {
      getProps: async () => {
        let data = await PleromaAPI.fetchStatuses("cd0.nl", "corne")

        data
      },
      revalidate: 900_000, // 15 min
    }

import React, {useCallback, useState} from "react"
import {Version, stickyStyle, Config} from "../types"
import {ChangeDiff} from "./change_diff"
import {ContextMenu} from "./context_menu"
import {VersionContextMenu} from "./version_context_menu"

export const VersionsList: React.FC<{
  config: Config
  loading: boolean
  versions: Array<Version>
}> = ({config, loading, versions}) => {
  if (loading) return <Info text="⌛" />

  if (versions.length === 0) return <Info text="No versions found." />

  const {columns, viewed} = config

  return (
    <table className="table">
      <thead style={{...stickyStyle, top: 47}}>
        <tr>
          {columns.version_id && <th>Version ID</th>}
          {columns.item_type && <th>Item Type</th>}
          {columns.item_id && <th>Item ID</th>}
          {columns.event && <th>Event</th>}
          {columns.whodunnit && <th>Whodunnit</th>}
          {columns.time && <th>Time</th>}
          {columns.changes && <th>Changes</th>}
          {columns.actions && (
            <th>
              Actions&nbsp;
              <Undo config={config} />
            </th>
          )}
        </tr>
      </thead>

      <tbody>
        {versions.map((v, i) => {
          if (viewed.includes(v.id)) return null

          return (
            <tr key={i} data-ci-type="version-row" data-ci-id={v.id}>
              {columns.version_id && <td>{v.id}</td>}
              {columns.item_type && <td>{v.item_type}</td>}
              {columns.item_id && <td>{v.item_id}</td>}
              {columns.event && <td>{v.event}</td>}
              {columns.whodunnit && <TdWhodunnit v={v} />}
              {columns.time && <TdTime v={v} />}
              {columns.changes && <TdChanges v={v} />}
              {columns.actions && <TdActions config={config} v={v} />}
            </tr>
          )
        })}
      </tbody>
    </table>
  )
}

const Info = ({text}: {text: string}) => (
  <p className="d-flex justify-content-center">{text}</p>
)

const Undo = ({config: {viewed, setViewed}}: {config: Config}) => {
  const undo = useCallback(() => {
    setViewed(viewed.slice(0, -1))
  }, [viewed, setViewed])

  return (
    <span
      style={viewed.length === 0 ? {visibility: "hidden"} : {}}
      onClick={() => undo()}
    >
      ⏪
    </span>
  )
}

const TdWhodunnit = ({v}: {v: Version}) => (
  <td>
    {(v.whodunnit && (
      <a href={v.user_url || "#"} title={v.whodunnit}>
        {truncate(v.whodunnit, 8)}
      </a>
    )) ||
      "–"}
  </td>
)

const TdTime = ({v}: {v: Version}) => (
  <td>{v.created_at.replace("T", " ").replace(/\+.*/, "")}</td>
)

const TdChanges = ({v}: {v: Version}) => (
  <td>{v.changeset && <ChangeDiff changeset={v.changeset} />}</td>
)

const TdActions = ({config, v}: {config: Config; v: Version}) => {
  const [menuCoords, setMenuCoords] = useState<null | [number, number]>(null)
  const showMenu = useCallback(
    (event: React.MouseEvent) => {
      event.preventDefault()
      ContextMenu.closeAll()
      setMenuCoords([event.clientX, event.clientY])
    },
    [setMenuCoords]
  )

  return (
    <td>
      <button
        className="btn btn-outline-secondary rounded-circle px-3"
        data-ci-type="version-action-button"
        onClick={showMenu}
      >
        ⋮
      </button>

      <VersionContextMenu
        config={config}
        coords={menuCoords}
        setCoords={setMenuCoords}
        version={v}
      />
    </td>
  )
}

const truncate = (str: string, len: number) => {
  if (!str || str.length <= len) return str
  return str.substring(0, len) + "…"
}

import React, {useCallback} from "react"
import {Version, VersionContextMenuProps} from "../types"
import {ContextMenu} from "./context_menu"
import {FullObjectModal} from "./full_object_modal"

export const VersionContextMenu = (props: VersionContextMenuProps) =>
  props.coords ? <VersionContexMenuComponent {...props} /> : null

const VersionContexMenuComponent = ({
  config,
  coords,
  version,
  setCoords,
}: VersionContextMenuProps) => (
  <ContextMenu
    className="bg-light border border-bottom-0 p-0"
    coords={coords}
    setCoords={setCoords}
  >
    <div className="d-flex flex-column" style={{cursor: "pointer"}}>
      <MenuItem show>
        <div
          onClick={() => {
            setCoords(null)
            config.setViewed([...config.viewed, version.id])
          }}
        >
          <input type="checkbox" checked={false} />
          &nbsp;
          <span>Viewed</span>
        </div>
      </MenuItem>

      <MenuItem show={!!version.object}>
        <FullObjectModal object={version.object} title="👁️ Before" />
      </MenuItem>

      <MenuItem show={!!version.changeset}>
        <FullObjectModal
          object={merge(version.object, version.changeset)}
          title="👁️ After"
        />
      </MenuItem>

      <MenuItem show={!!version.item_url}>
        <a
          href={version.item_url}
          style={{textDecoration: "none"}}
          target="_blank"
        >
          ↗️ See live
        </a>
      </MenuItem>

      <MenuItem show={!/[?&]item_id/.test(window.location.search)}>
        <a
          href={`${window.location.pathname}?item_type=${version.item_type}&item_id=${version.item_id}`}
          style={{textDecoration: "none"}}
        >
          📌 Track item
        </a>
      </MenuItem>

      <MenuItem show={config.allowRollback}>
        <RollBack version={version} />
      </MenuItem>
    </div>
  </ContextMenu>
)

const MenuItem = ({
  children,
  show,
}: {
  children: React.ReactNode
  show: boolean
}) => show && <div className="border-bottom p-2">{children}</div>

const merge = (object: Version["object"], changeset: Version["changeset"]) => {
  const newState = {...object}
  Object.entries(changeset).forEach(([k, [_, newValue]]) => {
    newState[k] = newValue
  })
  return newState
}

const RollBack = ({version: {event, id}}: {version: Version}) => {
  const showRollBackDialog = useCallback(() => {
    if (confirm(`${rollBackInfo[event]}! Are you sure you want to do this?`)) {
      rollBack(id)
    }
  }, [event, id])

  return <span onClick={() => showRollBackDialog()}>↩️ Roll back</span>
}

const rollBackInfo = {
  create: "As this is a `create` version, this will destroy the record",
  destroy: "As this is a `destroy` version, this will restore the record",
  update: "This will put the record back in the state before this version",
}

const rollBack = (id: Version["id"]) => {
  fetch(`${window.location.pathname}/versions/${id}`, {method: "PATCH"})
    .then((response) => response.json())
    .then((data) => {
      alert(data.message)
      if (data.success) window.location.reload()
    })
}

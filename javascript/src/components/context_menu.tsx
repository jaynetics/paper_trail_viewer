import React, {CSSProperties, useEffect, useMemo} from "react"

export const ContextMenu = ({
  children,
  className,
  coords,
  setCoords,
  zIndex = 15,
}: {
  children: React.ReactNode
  className?: string
  coords: [number, number]
  setCoords: Function
  zIndex?: number
}) => {
  useEffect(() => {
    const exit = () => setCoords(null)
    const exitOnEsc = ({keyCode}: {keyCode: number}) => keyCode === 27 && exit()

    document.body.addEventListener("close_all_contextmenus", exit)
    document.body.addEventListener("contextmenu", exit)
    document.body.addEventListener("keydown", exitOnEsc)
    window.addEventListener("hashchange", exit)

    return () => {
      document.body.removeEventListener("close_all_contextmenus", exit)
      document.body.removeEventListener("contextmenu", exit)
      document.body.removeEventListener("keydown", exitOnEsc)
      window.removeEventListener("hashchange", exit)
    }
  }, [setCoords])

  if (!coords) return null

  const [x, y] = coords

  const menuStyle = useMemo(() => {
    const style = {position: "fixed", zIndex} as CSSProperties

    // extend from coords towards center of window
    if (x < window.innerWidth / 2) style.left = x
    else style.right = window.innerWidth - x
    if (y < window.innerHeight / 2) style.top = y
    else style.bottom = window.innerHeight - y

    return style
  }, [x, y])

  return (
    <div
      className={className}
      onClick={(e) => e.stopPropagation()}
      style={menuStyle}
    >
      {children}
    </div>
  )
}

ContextMenu["closeAll"] = () =>
  document.body.dispatchEvent(new Event("close_all_contextmenus"))

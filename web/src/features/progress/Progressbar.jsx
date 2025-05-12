import React from "react"
import { useNuiEvent } from "../../hooks/useNuiEvent"
import { fetchNui } from "../../utils/fetchNui"
import ScaleFade from "../../transitions/ScaleFade"

const Progressbar = () => {
  const [visible, setVisible] = React.useState(false)
  const [label, setLabel] = React.useState("")
  const [duration, setDuration] = React.useState(0)
  const [progress, setProgress] = React.useState(0)

  // Calculate percentage during animation
  React.useEffect(() => {
    if (!visible || duration === 0) {
      setProgress(0)
      return
    }

    const startTime = Date.now()
    const interval = setInterval(() => {
      const elapsed = Date.now() - startTime
      const newProgress = Math.min((elapsed / duration) * 100, 100)
      setProgress(newProgress)
      if (newProgress >= 100) clearInterval(interval)
    }, 16) // ~60fps

    return () => clearInterval(interval)
  }, [visible, duration])

  useNuiEvent("progressCancel", () => setVisible(false))

  useNuiEvent("progress", data => {
    setVisible(true)
    setLabel(data.label)
    setDuration(data.duration)
  })

  return (
    <div className="w-full flex items-center justify-center absolute bottom-12">
      <ScaleFade
        visible={visible}
        onExitComplete={() => fetchNui("handleProgressComplete")}
      >
        <div className="w-[450px] flex flex-col items-center gap-2">
          {/* Label and Percentage */}
          <div className="flex items-center justify-between w-full px-2">
            <span className="text-lg font-semibold text-white drop-shadow-[0_2px_2px_rgba(0,0,0,0.8)]">
              {label}
            </span>
            <span className="text-lg font-medium text-white/90 drop-shadow-[0_2px_2px_rgba(0,0,0,0.8)]">
              {Math.round(progress)}%
            </span>
          </div>

          {/* Progress Bar Container */}
          <div className="w-full h-3 bg-background/80 rounded-full overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.4)] relative">
            {/* Progress Fill */}
            <div
              className="h-full bg-foreground shadow-[0_0_10px_rgba(59,130,246,0.7)]"
              onAnimationEnd={() => setVisible(false)}
              style={{
                animation:
                  visible && duration > 0
                    ? `progress-bar linear ${duration}ms`
                    : "none"
              }}
            >
              {/* Inner highlight */}
              <div className="absolute inset-0 bg-background/20 rounded-full" />
            </div>
          </div>

          {/* Bottom Glow */}
          <div className="w-3/4 h-1 bg-foreground/40 rounded-full blur-md absolute -bottom-1 opacity-70 animate-pulse" />
        </div>
      </ScaleFade>
    </div>
  )
}

export default Progressbar

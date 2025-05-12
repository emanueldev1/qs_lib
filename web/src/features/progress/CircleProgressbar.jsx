import React from "react"
import { useNuiEvent } from "../../hooks/useNuiEvent"
import { fetchNui } from "../../utils/fetchNui"
import ScaleFade from "../../transitions/ScaleFade"

const CircleProgressbar = () => {
  const [visible, setVisible] = React.useState(false)
  const [progressDuration, setProgressDuration] = React.useState(0)
  const [position, setPosition] = React.useState("middle")
  const [value, setValue] = React.useState(0)
  const [label, setLabel] = React.useState("")

  useNuiEvent("progressCancel", () => {
    setValue(99)
    setVisible(false)
  })

  useNuiEvent("circleProgress", data => {
    if (visible) return
    setVisible(true)
    setValue(0)
    setLabel(data.label || "")
    setProgressDuration(data.duration)
    setPosition(data.position || "middle")
    const onePercent = data.duration * 0.01
    const updateProgress = setInterval(() => {
      setValue(previousValue => {
        const newValue = previousValue + 1
        if (newValue >= 100) clearInterval(updateProgress)
        return newValue
      })
    }, onePercent)
  })

  // Calculate stroke-dasharray for the progress circle
  const radius = 33.5
  const circumference = 2 * Math.PI * radius
  const strokeDashoffset = circumference - (value / 100) * circumference

  return (
    <>
      <style>
        {`
        @keyframes progress-circle {
          from {
            stroke-dashoffset: ${2 * Math.PI * 33.5};
          }
          to {
            stroke-dashoffset: 0;
          }
        }
    `}
      </style>

      <div
        className={`w-full flex justify-center items-center absolute bottom-0 ${
          position === "middle" ? "h-full" : "h-1/5"
        }`}
      >
        <ScaleFade
          visible={visible}
          onExitComplete={() => fetchNui("handleProgressComplete")}
        >
          <div
            className={`flex flex-col items-center gap-2 ${
              position === "middle" ? "mt-6" : ""
            }`}
          >
            {/* Circular Progress */}
            <div className="relative w-[90px] h-[90px]">
              <svg className="w-full h-full" viewBox="0 0 75 75">
                {/* Background Circle */}
                <circle
                  cx="37.5"
                  cy="37.5"
                  r={radius}
                  className="fill-none stroke-foreground/50 stroke-[7px]"
                />
                {/* Progress Circle */}
                <circle
                  cx="37.5"
                  cy="37.5"
                  r={radius}
                  className="fill-none stroke-background stroke-[7px] transform -rotate-90 origin-center"
                  style={{
                    strokeDasharray: circumference,
                    strokeDashoffset,
                    animation:
                      visible && progressDuration > 0
                        ? `progress-circle ${progressDuration}ms linear forwards`
                        : "none"
                  }}
                  onAnimationEnd={() => setVisible(false)}
                />
              </svg>
              {/* Percentage Text */}
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-xl font-mono text-white/90 drop-shadow-[0_2px_2px_rgba(0,0,0,0.8)]">
                  {value}%
                </span>
              </div>
              {/* Glow Effect */}
              <div className="absolute inset-0 rounded-full bg-background/30 blur-md opacity-50 animate-pulse" />
            </div>

            {/* Label */}
            {label && (
              <span className="text-base text-white/90 h-6 text-center drop-shadow-[0_2px_2px_rgba(0,0,0,0.8)]">
                {label}
              </span>
            )}
          </div>
        </ScaleFade>
      </div>
    </>
  )
}

export default CircleProgressbar

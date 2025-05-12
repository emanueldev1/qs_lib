import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"

/**
 * A wrapper component for the FontAwesomeIcon that adds support for various animation props.
 *
 * @component
 * @param {Object} props - The properties passed to the component.
 * @param {string} [props.animation] - The animation type to apply to the icon. 
 *                                      Supported values: "spin", "spinPulse", "spinReverse", 
 *                                      "pulse", "beat", "fade", "beatFade", "bounce", "shake".
 * @returns {JSX.Element} The rendered FontAwesomeIcon component with the specified animations.
 */
const LibIcon = props => {
  const animationProps = {
    spin: props.animation === "spin",
    spinPulse: props.animation === "spinPulse",
    spinReverse: props.animation === "spinReverse",
    pulse: props.animation === "pulse",
    beat: props.animation === "beat",
    fade: props.animation === "fade",
    beatFade: props.animation === "beatFade",
    bounce: props.animation === "bounce",
    shake: props.animation === "shake"
  }

  return <FontAwesomeIcon {...props} {...animationProps} />
}

export default LibIcon

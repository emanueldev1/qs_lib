import LibIcon from "../../../../components/LibIcon"
import { Button } from "@/components/ui/button"

const HeaderButton = ({ icon, canClose, iconSize, handleClick }) => {
  return (
    <Button
      size="icon"
      className="bg-background hover:!bg-background/70 hover:cursor-pointer hover:scale-105 context-menu-cls-btn"
      disabled={canClose === false}
      onClick={handleClick}
    >
      <LibIcon
        className="text-foreground"
        icon={icon}
        fontSize={iconSize}
        fixedWidth
      />
    </Button>
  )
}

export default HeaderButton

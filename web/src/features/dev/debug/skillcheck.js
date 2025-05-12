import { debugData } from "../../../utils/debugData"

export const debugSkillCheck = () => {
  debugData([
    {
      action: "startSkillCheck",
      data: {
        difficulty: ["easy", "easy", "hard"],
        inputs: ["W", "A", "S", "D"]
      }
    }
  ])
}

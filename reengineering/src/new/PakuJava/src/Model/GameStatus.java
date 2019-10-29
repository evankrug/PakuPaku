package Model;

public enum GameStatus {
    mainMenu,
    play,
    highScore,
    staring,
    pakuDiedButStillHasLifeLeft,
    GameOver,
    nextLevel,
    closing;

    public static String getStatusUI(GameStatus input) {
        if(input == null)
            return null;
        switch(input){
            case mainMenu: return "main_menu";
            case play: return "play";
            case highScore: return "high_score";
            case staring: return "play";
            case pakuDiedButStillHasLifeLeft: return "play";
            case GameOver: return "play";
            case nextLevel: return "play";
            case closing: return "play";

        }
        return null;
    }
}

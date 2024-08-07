import edu.princeton.cs.algs4.Bag;
import edu.princeton.cs.algs4.In;
import edu.princeton.cs.algs4.StdOut;
import edu.princeton.cs.algs4.Stopwatch;
import java.util.HashSet;

public class BoggleSolver {
    private BoggleBoard board;
    private Bag<Integer>[] adjacentTiles;
    private Node root = new Node();       // root node

    private static class Node {
        private String word;                        // true if the path to this Node is a word in the trie
        private final Node[] next = new Node[26];   // characters are implicitly defined by link index
    }

    public void put(String key) {
        root = put(root, key, 0);
    }

    private Node put(Node x, String key, int d) {
        // create a new node if this is a new longer key
        if (x == null)              x = new Node();
        if (d == key.length()) {
            x.word = key;
            return x;
        }

        // calculate the index of the char at d
        char c = key.charAt(d);     // apparently chars are implicitly converted to int
        x.next[c - 'A'] = put(x.next[c - 'A'], key, d + 1);
        return x;
    }

    public boolean wordPrefix(String key) {
        Node x = get(root, key, 0);
        return x != null;
    }

    public boolean containsWord(String key) {
        Node x = get(root, key, 0);
        return x != null && x.word != null;
    }

    // get the node associated with the key in the trie
    private Node get(Node x, String key, int d) {
        if (x == null)              return null;
        if (key.length() == d)      return x;


        char c = key.charAt(d);
        return get(x.next[c - 'A'], key, d + 1);
    }


    // Initializes the data structure using the given array of strings as the dictionary.
    // (You can assume each word in the dictionary contains only the uppercase letters A through Z.)
    public BoggleSolver(String[] dictionary) {
        for (String word : dictionary)
            put(word);
    }

    // Returns the set of all valid words in the given Boggle board, as an Iterable.
    public Iterable<String> getAllValidWords(BoggleBoard board) {
        this.board = board;
        int totalTiles = board.rows() * board.cols();

        // precompute the adjacent tiles of all tiles in the board
        adjacentTiles = (Bag<Integer>[]) new Bag[totalTiles];
        for (int k = 0; k < totalTiles; k++)
            adjacentTiles[k] = adjacentTiles(k);

        HashSet<String> validWords = new HashSet<>();
        boolean[] visited = new boolean[totalTiles];
        // dfs from vertex u to vertex v to search all valid paths, reuse the visited array by resetting
        for (int i = 0; i < totalTiles; i++) {
            for (int j = 0; j < totalTiles; j++) {
                if (i != j)     DFS(i, j, new StringBuilder(), visited, validWords);
            }
        }

        return validWords;
    }

    // Returns the score of the given word if it is in the dictionary, zero otherwise.
    // (You can assume the word contains only the uppercase letters A through Z.)
    public int scoreOf(String word) {
        int maximumScore = 11;
        int maximumScoreLength = 8;
        if (containsWord(word))  {
            int[] scores = {0, 0, 0, 1, 1, 2, 3, 5};   // 8-letter or more gains 11 points
            if (word.length() < maximumScoreLength)     return scores[word.length()];
            else                                        return maximumScore;
        }

        return 0;
    }

    // identify the valid paths that satisfy the following constrains
    //  - a simple path between index u and v (which corresponds to a tile in the board)
    //  - a path of index corresponding to a word in the dictionary
    //      (prune search if the current path is not a prefix of any word in the dictionary)
    private void DFS(int u, int v, StringBuilder word, boolean[] visited, HashSet<String> validWords) {
        if (visited[u]) return;

        visited[u] = true;

        String curChar;
        char c = board.getLetter(u / board.cols(), u % board.cols());
        if (c == 'Q')   curChar = "QU";
        else            curChar = String.valueOf(c);
        String curWord = word.append(curChar).toString();

        if (u == v) {
            int minimumWordLength = 3;      // for a boggle game
            if (curWord.length() >= minimumWordLength && containsWord(curWord)) {
                validWords.add(curWord);
            }
        }

        else {
            for (int next : adjacentTiles[u]) {
                // do not do dfs on paths that
                //      don't form prefix of a valid word and paths that contain duplicates
                char n = board.getLetter(next / board.cols(), next % board.cols());
                String nextWord = word.toString() + n;
                if (!visited[next] && wordPrefix(nextWord)) {
                    DFS(next, v, word, visited, validWords);
                }
            }
        }

        visited[u] = false;
        for (int i = 0; i < curChar.length(); i++) {
            word.deleteCharAt(word.length() - 1);
        }
    }

    //  precompute this for every tile, there is no need to calculate again
    private Bag<Integer> adjacentTiles(int u) {
        Bag<Integer> adj = new Bag<>();

        int width = board.cols();
        int row = u / width;
        int col = u % width;

        if (row > 0) {
            adj.add(((row - 1) * width) + col);                                     // direct top
            if (col > 0)            adj.add(((row - 1) * width) + (col - 1));       // top-left
            if (col + 1 < width)    adj.add(((row - 1) * width) + (col + 1));       // top-right
        }

        if (col > 0)                adj.add((row * width) + (col - 1));             // left
        if (col + 1 < width)        adj.add((row * width) + (col + 1));             // right

        if (row + 1 < board.rows()) {
            adj.add(((row + 1) * width) + col);                                     // direct bottom
            if (col > 0)            adj.add(((row + 1) * width) + (col - 1));       // bottom-left
            if (col + 1 < width)    adj.add(((row + 1) * width) + (col + 1));       // bottom-right
        }

        return adj;
    }

    public static void main(String[] args) {
        Stopwatch stopwatch = new Stopwatch();

        In in = new In(args[0]);
        String[] dictionary = in.readAllStrings();
        BoggleSolver solver = new BoggleSolver(dictionary);

        for (int i = 1; i < args.length; i++) {
            BoggleBoard board = new BoggleBoard(args[i]);
            int score = 0;
            for (String word : solver.getAllValidWords(board)) {
                score += solver.scoreOf(word);
            }
            StdOut.printf("Filename '%s'    Score = %d\n", args[i], score);
        }

        System.out.printf("Total Time: %f\n", stopwatch.elapsedTime());
    }
}
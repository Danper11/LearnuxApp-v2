package com.learnux.ui;

import javax.sound.sampled.*;

public class SoundPlayer {

    private static void play(int[][] tonesMs) {
        new Thread(() -> {
            try {
                float sr = 44100f;
                AudioFormat af = new AudioFormat(sr, 16, 1, true, false);
                DataLine.Info info = new DataLine.Info(SourceDataLine.class, af);
                SourceDataLine line = (SourceDataLine) AudioSystem.getLine(info);
                line.open(af, 4096);
                line.start();

                for (int[] tm : tonesMs) {
                    int freq = tm[0], ms = tm[1];
                    int samples = (int)(sr * ms / 1000);
                    byte[] buf = new byte[samples * 2];
                    for (int i = 0; i < samples; i++) {
                        double angle = 2 * Math.PI * i * freq / sr;
                        double fadeIn  = Math.min(i / (sr * 0.008), 1.0);
                        double fadeOut = Math.min((samples - i) / (sr * 0.025), 1.0);
                        short val = (short)(Math.sin(angle) * 16000 * fadeIn * fadeOut);
                        buf[i * 2]     = (byte)(val & 0xff);
                        buf[i * 2 + 1] = (byte)((val >> 8) & 0xff);
                    }
                    line.write(buf, 0, buf.length);
                }
                line.drain();
                line.close();
            } catch (Exception ignored) {}
        }).start();
    }

    public static void playCorrect() {
        play(new int[][]{{370, 90}, {494, 130}});
    }

    public static void playWrong() {
        play(new int[][]{{280, 70}, {210, 130}});
    }

    public static void playGameOver() {
        play(new int[][]{{330, 120}, {220, 120}, {165, 200}});
    }

    public static void playLevelPass() {
        play(new int[][]{{523, 80}, {659, 80}, {784, 80}, {1047, 160}});
    }
}

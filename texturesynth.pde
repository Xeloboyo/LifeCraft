int[] CoherentSynthesis(int[] sample, int SW, int SH, ArrayList<Integer> sets, int N, int OW, int OH, double t, boolean indexed)
  {
    int[] result = new int[OW * OH];
    Integer[] origins = new Integer[OW * OH];
    Random random = new Random();

    for (int i = 0; i < result.length; i++)
    {
      int x = i % OW, y = i / OW;
      HashMap candidates = new HashMap<Integer, Double>();
      boolean[][] mask = new boolean[SW][SH];

      for (int dy = -1; dy <= 1; dy++)
      for (int dx = -1; dx <= 1; dx++)
        {
          int sx = (x + dx + OW) % OW, sy = (y + dy + OH) % OH;
          Integer origin = origins[sy * OW + sx];
          if ((dx != 0 || dy != 0) && origin != null)
          {
            for (int p : sets)
            {
              int ox = (p % SW - dx + SW) % SW, oy = (p / SW - dy + SH) % SH;
              double s = Similarity(oy * SW + ox, sample, SW, SH, i, result, OW, OH, N, origins, indexed);

              if (!mask[ox][oy]) 
                candidates.put(ox + oy * SW, Math.pow(100d, (s / t)));
              mask[ox][oy] = true;
            }
          }
        }

      int shifted = !candidates.isEmpty() ? Random(candidates,random.nextDouble()) : random.nextInt(SW) + random.nextInt(SH) * SW;
      origins[i] = shifted;
      result[i] = sample[shifted];
    }

    return result;
  }
  
  double Similarity(int i1, int[] b1, int w1, int h1, int i2, int[] b2, int w2, int h2, int N, Integer[] origins, boolean indexed)
  {
    double sum = 0;
    int x1 = i1 % w1, y1 = i1 / w1, x2 = i2 % w2, y2 = i2 / w2;

    for (int dy = -N; dy <= 0; dy++) 
    for (int dx = -N; (dy < 0 && dx <= N) || (dy == 0 && dx < 0); dx++)
      {
        int sx1 = (x1 + dx + w1) % w1, sy1 = (y1 + dy + h1) % h1;
        int sx2 = (x2 + dx + w2) % w2, sy2 = (y2 + dy + h2) % h2;

        int c1 = b1[sx1 + sy1 * w1];
        int c2 = b2[sx2 + sy2 * w2];

        if (origins == null || origins[sy2 * w2 + sx2] != null)
        {
          if (indexed){ sum += c1 == c2 ? 1 : -1;}
          else
          {
            
            sum -= (double)(sqrd(red(c1)- red(c2)) + sqrd(green(c1) - green(c2)) +sqrd(blue(c1) - blue(c2))) / 65536.0;
          }
        }
      }

    return sum;
  }


static List<Integer>[] Analysis(int[] bitmap, int width, int height, int K, int N, bool indexed)
  {
    int area = width * height;
    ArrayList<Integer> result[] = new ArrayList[area];
    List<Integer> points = new ArrayList<Integer>();
    for (int i = 0; i < area; i++) points.add(i);

    double[] similarities = new double[area * area];
    for (int i = 0; i < area; i++) for (int j = 0; j < area; j++)
        similarities[i * area + j] = similarities[j * area + i] != 0 ? similarities[j * area + i] : 
          Similarity(i, bitmap, width, height, j, bitmap, width, height, N, null, indexed);

    for (int i = 0; i < area; i++)
    {
      result[i] = new ArrayList<Integer>();
      List<Integer> copy = new ArrayList<Integer>(points);

      result[i].add(i);
      copy.remove(i);

      for (int k = 1; k < K; k++)
      {
        double max = -1E-4;
        int argmax = -1;

        for (int p : copy)
        {
          double s = similarities[i * area + p];
          if (s > max)
          {
            max = s;
            argmax = p;
          }
        }

        result[i].add(argmax);
        copy.remove(argmax);
      }
    }

    return result;
  }


public double sumArray(Double[] array){
  double s = 0;
  for(Double d:array){
    s+=d;
  }
  return s;
}

public int Random(Double[] array, double r)
  {
    double sum = sumArray(array);

    if (sum <= 0) 
    {
      for (int j = 0; j < array.length; j++) 
        array[j] = 1d;
        
      sum = sumArray(array);
    }

    for (int j = 0; j < array.length; j++) array[j] /= sum;

    int i = 0;
    double x = 0;

    while (i < array.length)
    {
      x += array[i];
      if (r <= x) return i;
      i++;
    }

    return 0;
  }

int Random(HashMap<Integer, Double> dic, double r){
  return dic.keySet().toArray(new Integer[]{})[Random(dic.values().toArray(new Double[]{}),r)];
};

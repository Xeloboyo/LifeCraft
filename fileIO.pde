import java.io.*;
class Saver
{
    void save(String filename,int[][] terraintype,float[][] terrainvalues,float[][] ores)
    {
        try
        {
          File f=new File(System.getProperty("sys.dir")+filename+".txt");
          RandomAccessFile fr=new RandomAccessFile(f,"rw");
          fr.writeInt(terraintype.length);
          fr.writeInt(terraintype[0].length);
          for (int i=0; i<terraintype.length; i++)
          {
              for (int j=0; j<terraintype[i].length; j++)
              {
                  fr.writeInt(terraintype[i][j]);
                  fr.writeFloat(terrainvalues[i][j]);
                  fr.writeFloat(ores[i][j]);
              }
          }
          fr.close();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }
    void load(String filename)
    {
        try
        {
            JSONObject objData;
            BufferedReader br = createReader("dwadwadaw.txt");
            String accumilative= "";
            String s;
            while((s=br.readLine())!=null){
              accumilative +=s;
            }
            objData = parseJSONObject(accumilative);
            
            //todo
            
            RandomAccessFile fr=new RandomAccessFile(System.getProperty("sys.dir")+filename+".txt","rw");
            int width=fr.readInt();
            int height=fr.readInt();
            
            for (int i=0; i<width; i++)
            {
                for (int j=0; j<height; j++)
                {
                    //land[i][j]=fr.readInt();
                    //heights[i][j]=fr.readFloat();
                    //ores[i][j]=fr.readFloat();
                }
            }
            fr.close();
            
        }
        catch(Exception e)
        {
          count=0;
            filenotfound=true;
            
        }
    }
}

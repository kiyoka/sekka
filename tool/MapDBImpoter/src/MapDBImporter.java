import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.Scanner;
import java.util.SortedMap;
import java.util.TreeMap;

import org.mapdb.BTreeMap;
import org.mapdb.DB;
import org.mapdb.DBMaker;
import org.mapdb.Serializer;

import com.intellij.openapi.util.io.FileUtil;

public class MapDBImporter {

	static final String inputTsvName = "SEKKA-JISYO-1.6.2.N.tsv";
	static final String dbFileName   = "SEKKA-JISYO-1.6.2.N.mapdb";

	public static void main(String[] args){

		FileUtil.delete(new File(dbFileName));
		
		/**
		 * Open db file
		 */
		File dbFile = new File(dbFileName);
		DB db = DBMaker
				.fileDB(dbFile)
				.make();


		long time = System.currentTimeMillis();
		SortedMap<String,String> source = new TreeMap<>();

		try {
			InputStreamReader in = new InputStreamReader(new FileInputStream(inputTsvName), "UTF-8");
			Scanner scanner = new Scanner(in);

			if(true) {
				while(scanner.hasNext()) {
					String line = scanner.nextLine();
					String fields[] = line.split("\t");
					if(2 <= fields.length) {
						String key = fields[0];
						String value = fields[1];
						source.put(key, value);
					}
				}
			}
			else {
				for(int i = 0 ; i < 1000000 ; i++) {
					String key = String.format("key%06d", i);
					String value = String.format("value%06d", i);
					source.put(key, value);
				}
			}
						
			//create map with TreeMap source
			BTreeMap<String, String> map = db.treeMap("sekka")
					.keySerializer(Serializer.STRING)
					.valueSerializer(Serializer.STRING)
					.createFrom(source);
		}
		catch(FileNotFoundException e) {
			e.printStackTrace();
			System.exit(1);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			System.exit(1);
		}

		
		db.close();

		System.out.println("Finished; total time: "+(System.currentTimeMillis()-time)/1000+"s; there are "+source.size()+" items in map");
	}
}

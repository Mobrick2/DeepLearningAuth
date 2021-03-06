#include<iostream>
#include<set>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include<vector>
using namespace std;

int NUMSCALE = 1000000;
int RANDOMRANGE = 2000;

bool ErrorFlag = false;

void readInputdata( long int *input, int *inputIndex, char * filename);
void readInputIndex( int *input, char * filename);
void readWeightParmaters( long int * weight, char * filename);
void samplingUniqueValue(int samplesize, long int * input, int dim);

int main(int argc, char **argv) {

  //read the input data into memory : 2000 test data example with 784 dimensions 
  int size = 6698834;
  long int *input = (long int *)malloc( size * sizeof(long int));
  int *inputIndex = (int *)malloc(1680 *  sizeof(int));  
  readInputdata(input, inputIndex, "/home/bzhang41/deeplearninglib/timit-preprocessor/data/processed/test.13.ark");

  //printf("%ld %ld %ld\n", input[0], input[1000000], input[6698833]);
  //printf("%d %d %d\n", inputIndex[0], inputIndex[1000], inputIndex[1679]);
  
  int n1 = 512, dim = 784;
  long int *fc1_weight = (long int * ) malloc(dim * n1 * sizeof (long int));
  readWeightParmaters(fc1_weight, "/home/bzhang41/DLVerification/dataset/fc1_weight.txt");

  //estimate the input size
  srand (time(NULL));
 
  /* 
  int batchsize = 100;
  double basicinputsize = 0 , optimizedinputsize = 0;
  set<long int> uniqueInput;
  for ( int i = 0 ; i < batchsize; ++ i){

	int randomindex = rand() % 6698700;
	basicinputsize += 40;
	for ( int j = randomindex ; j < randomindex+40; ++ j ){
           uniqueInput.insert(input[j]);
	}
  }

  optimizedinputsize = (double) uniqueInput.size() * 65.0 / 1024.0 / 1024.0 + 7 * (basicinputsize-uniqueInput.size()) / 1024.0 / 1024.0; 
  basicinputsize = basicinputsize * 65.0 / 1024.0/ 1024.0;
  printf("%f\t%f\n",basicinputsize,optimizedinputsize);
  */
   
  
  int batchsize = 100;
  double basicsize2 = 0, optimizedsize2 = 0 ;
  double basicsize3 = 0, optimizedsize3 = 0 ;
  double basicsize4 = 0, optimizedsize4 = 0 ;
  double basicsize5 = 0, optimizedsize5 = 0 ;

  int h1num = 50, h2num = 200, h3num = 200, h4num = 50, outputnum = 61; 
  
  srand (time(NULL));
  dim = 100;
  for ( int i = 0 ; i < batchsize; ++ i){

        //size of input data
	int inputID = rand() % 6698700;

 	//size of zk1
	set<long int> uniqz;
	for ( int j = 0 ; j < h1num ; ++ j){

	    long int z = 0 ;
	    for ( int k = 0 ; k < dim; ++ k ){
		z += input[inputID+k] * fc1_weight[rand() % (784*n1)];
	    }

	    long int tmp = z; int digitsN = 0 ;
	    while (tmp ){
		digitsN ++;
		tmp /= 10;
	    }
	    basicsize2 += (double) digitsN / 1024.0/1024.0;
	    //printf("%d\n",digitsN);
	    uniqz.insert(z);
	}

	for ( auto itm : uniqz){
	    long int tmp = itm; int digitsN = 0 ;
	    while ( tmp ){
		digitsN ++;
		tmp /= 10;
	    }
            optimizedsize2 += (double) digitsN / 1024.0/1024.0;
	}
  

	//size of zk2
	uniqz.clear();
        for ( int j = 0 ; j < h1num ; ++ j){

            long int z = 0 ;
            for ( int k = 0 ; k < dim; ++ k ){
		z += input[inputID + k] * fc1_weight[rand() % (784*n1)];
            }

            long int tmp = z; int digitsN = 0 ;
            while (tmp ){
                digitsN ++;
                tmp /= 10;
            }
            basicsize3 += (double) digitsN / 1024.0/1024.0;
            uniqz.insert(z);
        }

        for ( auto itm : uniqz){
            long int tmp = itm; int digitsN = 0 ;
            while ( tmp ){
                digitsN ++;
                tmp /= 10;
            }
            optimizedsize3 += (double) digitsN / 1024.0/1024.0;
        }

        //size of weight increment
	if ( i == 0 ) {
		set<long int> uniqweight;
        	for ( int j = 0 ; j < dim * h1num + h4num*outputnum;  ++ j){
	    		long int tmpweight = fc1_weight[rand() % (784*n1)];
	    		uniqweight.insert(tmpweight);
		}
        
	//only count once for this part, since verify the weight increment
		optimizedsize4 += 65.0 * (double) uniqweight.size()/1024.0/1024.0;
		basicsize4 += (dim * h1num + (h4num*outputnum)) * 65 / 1024.0/1024.0;
	}
		
        //size of g^deltao
	set<long int> uniqweight;
        for ( int j = 0 ; j < outputnum; ++ j){
	    	long int tmpweight = fc1_weight[rand() % (784*n1)];
	    	uniqweight.insert(tmpweight);
	}
        
	basicsize4 += (((double) outputnum)* 65.0)/1024.0/1024.0 ; 
	optimizedsize4 += ( (double) uniqweight.size() * 65.0) / 1024.0/1024.0 ;	


	//cout << uniqweight.size() << endl;

	set<long int> uniqdelta;
        for ( int j = 0 ; j < h4num ; ++ j){
            long int tmpdelta = fc1_weight[rand() % (784*n1)];
            uniqdelta.insert(tmpdelta);

	    int digitsN = 0 ;
	    while( tmpdelta ){
		digitsN ++ ;
		tmpdelta /= 10;
	    }
	    //cout << digitsN << " ";
	    basicsize5 += (double) digitsN / 1024.0/1024.0;;
        }
	
	//cout << uniqdelta.size() << endl;
   
        for ( auto itm : uniqdelta){
            long int tmp = itm; int digitsN = 0 ;
            while ( tmp ){
                digitsN ++;
                tmp /= 10;
            }
            optimizedsize5 += (double) digitsN / 1024.0/1024.0;;
        }
	
  	if ( (i+1) % 100 == 0 )
  	 cout << basicsize2 <<  "\t" << optimizedsize2 << "\t"
       << basicsize3 << "\t" << optimizedsize3 << "\t" << basicsize4 << "\t" << optimizedsize4 << "\t" << 
	basicsize5  << "\t" << optimizedsize5 << endl;
	
  }
  

  /*
  int samplingtime = 1;
  int samplingsize[6] = {100,200,300,400,500,600};
  for ( int j = 0 ; j < 6 ; ++ j){
     for ( int i = 0 ; i < samplingtime; ++ i ){
	   samplingUniqueValue(samplingsize[j],input,dim);
     }
  }

  clock_t start, end;
  start  = clock();
  vector<int> vomap(1000,0);
  int j = 0 ;
  for ( int i = 0 ; i < 1000; ++ i ){
	j = i;
	if ( i == j ){
	   vomap[i] = i ;
	}
  }
  end = clock();
  cout << (((double) (end - start)) / CLOCKS_PER_SEC) << endl;
  */

  return 0;
}

void samplingUniqueValue(int samplesize, long int *input, int dim){
  
  vector<int> indexs;
  for ( int i = 0 ; i < samplesize; ++ i ){
        indexs.push_back(rand() % 2000);
  }

  set<long int> inputSet;
  for ( int i = 0 ; i < samplesize; ++ i ){
        for ( int j = 0 ; j < dim; ++ j ){
            inputSet.insert(input[i*dim+j]);
        }
  }

  cout << inputSet.size() << endl;

}

void readInputIndex( int *input, char * filename){
  
  char * pixstr = (char*) malloc( 20 * sizeof(char));
  int i = 0;
  char tmp;

  FILE *file;
  file = fopen(filename, "r");
  int count  = 0 ;
  //printf("file openned\n");

  if ( file != NULL ){

       while ( (tmp = (char)fgetc(file)) != EOF ){	
	 	
	   if  ( (tmp >= '0' && tmp <= '9')){             
	        pixstr[i++] = tmp;
		while ((tmp = (char)fgetc(file)) != '\n' ){
		    pixstr[i++] = tmp;
	  	}
		pixstr[i] = '\0';
		input[count++] = (int) (atof(pixstr));
		i = 0;
	   }
      }

      fclose(file);
  }
  else printf("file open error\n");
}

void readInputdata( long int  *input, int * inputIndex, char * filename){

  char * pixstr = (char*) malloc( 20 * sizeof(char));
  int i = 0;
  char tmp;

  FILE *file;
  file = fopen(filename, "r");
  int count  = 0 ;
  //printf("file openned\n");

  int long minvalue = 5000;
  int long maxvalue = 0;

  int dimentionCount = 0;
  if ( file != NULL ){

       while ( (tmp = (char)fgetc(file)) != EOF ){

           if (tmp != '[') continue;

           while ((tmp = (char)fgetc(file)) != EOF ){

                if  ( (tmp >= '0' && tmp <= '9') || tmp == '.' || tmp == '-'){
                    pixstr[i++] = tmp;
                    //printf("%c",tmp);

                    while ( ((tmp = (char)fgetc(file)) >= '0' &&
                        tmp <= '9') || tmp == '.' || tmp == '-' ){
                        pixstr[i++] = tmp;
                        //printf("%c",tmp);
                    }
                    pixstr[i] = '\0';
                    input[count++] = (long int) (NUMSCALE * atof(pixstr));
		   
	            if ( input[count-1] > maxvalue ) maxvalue = input[count-1] ;
		    if ( input[count-1] < minvalue ) minvalue = input[count-1] ;

                    i = 0 ;

                }

                if ( tmp == ']' ) {
                   //dimentionCount++;
                   inputIndex[dimentionCount++] = count ;
                   //dimentionCount = 0 ;
                   break;
   		}
          }
       }

       fclose(file);
  }
  else printf("file open error\n");
  //printf("min n=%ld\n", minvalue);
  //printf("max n=%ld\n", maxvalue);
  //printf("sample n=%u\n",dimentionCount);
  free(pixstr);

}

void readWeightParmaters( long int * weight, char * filename){

  char * pixstr = (char*) malloc( 20 * sizeof(char));
  int i = 0;
  char tmp;

  FILE *file;
  file = fopen(filename, "r");
  int count  = 0 ;

  if ( file != NULL ){

       while ( (tmp = (char)fgetc(file)) != EOF ){

           if (tmp == '[' || tmp == '\t' || tmp == '\n') continue;

           pixstr[i++] = tmp;
           if ( tmp == ' ' || tmp == ']'){
                pixstr[i-1] = '\0';
                if ( pixstr[0] != '\0' ) {
                        if ( pixstr[i-2] == '.' ) pixstr[i-2] = '\0';
                        weight[count++] = (long int) (atof(pixstr));
                        //printf("%ld\n", weight[count-1]);
                }
                i = 0;
           }
       }
       fclose(file);
  }
  else printf("file open error\n");

  //printf("n=%d\n", count);
  free(pixstr);
}


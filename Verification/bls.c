#include <pbc.h>
#include <pbc_test.h>
#include <stdbool.h>
#include <stdio.h>
#include <time.h>

int NUMSCALE = 1000000;
int RANDOMRANGE = 2000;
//Generator of G1 and G2
element_t g,h,l,l1;

/* Initialize the group generators */
void init_group_generators(pairing_t pairing);

/*Compress the proof to save communication cost */
unsigned char * compressG1( pairing_t pairing, element_t g1);
unsigned char * compressG2( pairing_t pairing, element_t g2);
int getsizeofGT( pairing_t pairing);

/*Proof of uni generated from client or server, i.e. g^a. */
void generate_Aproof(element_t a_enc, pairing_t pairing, long int a);    

/* Proof of unit create from the server or client side, i.e. g^w */
void create_Wproof(element_t w_enc, pairing_t pairing, long int w);

/* Proof of unit create from the client sidei, i.e. e(g^a,h^w) */
void generate_Uproof(element_t unit_enc, element_t ga, element_t hw, pairing_t pairing);

/*Proof of weighted sum from the client, i.e. l^r which is used to commitment */
void create_Rproof(mpz_t r, element_t gt, pairing_t pairing);

/* Proof of Pederson Commitment */
void generate_Cproof(element_t commit, element_t r_enc, element_t unit_enc, pairing_t pairing);

/* verify the unit value, i.e. e(g^a,h^w) ?= e(g,h)^(unit) */
bool verify_unit(pairing_t pairing, element_t ga, element_t hw, element_t unit_enc);

/* verify the weighted sum, i.e. z = a1w1 + a2w2; */
bool verify_wsum(pairing_t pairing, element_t accC, element_t accR, element_t accA);

void readInputdata( long int *input, char * filename);
void readWeightParmaters( long int * weight, char * filename);

void UnitVOConstructionTime(pairing_t paring, long int pix, long int w,
				element_t ga, element_t hw, element_t unit_enc);

int main(int argc, char **argv) {

  //read the input data into memory : 2000 test data example with 784 dimensions 
  int size = 2000, dim = 784;
  long int *input = (long int *)malloc(size * dim * sizeof(long int)); 
  readInputdata(input,"/home/bzhang41/DLVerification/dataset/testdata.txt");
  
  //read the weight parameter 784 * 512
  int n1 = 512;
  long int *fc1_weight = (long int * ) malloc(dim * n1 * sizeof (long int));
  readWeightParmaters(fc1_weight, "/home/bzhang41/DLVerification/dataset/fc1_weight.txt");
  
  /***Initial the pairing function***/
  pairing_t pairing;
  pbc_demo_pairing_init(pairing, argc, argv);
  init_group_generators(pairing);

  
  //First Layer Verification
  double unitvo_cons_time = 0;
  clock_t start, end;
  for ( int i = 0; i < 1 ; ++ i){
      for (int j = 0 ; j < 2 ; ++ j ){ //j < n1
         
          mpz_t R; mpz_init(R);
	  element_t PCOM; element_init_GT(PCOM, pairing);
	  long int wsum = 0;
 
	  for ( int k = 0 ; k < 10 ; ++ k){ // k < dim
	      long int w = (fc1_weight[k*dim+j]);
	      long int pix = (input[i*dim+k]);

	      start = clock();
              /**************** Client VO Generation ******************/
	      element_t ga, hw, unit_enc, pcom;
	      mpz_t r; element_t r_enc;

              create_Rproof(r, r_enc,pairing);
	      UnitVOConstructionTime(pairing,pix,w,ga,hw,unit_enc); 
    	      generate_Cproof(pcom,r_enc,unit_enc,pairing);

	      end = clock();
	      unitvo_cons_time += (((double) (end - start)) / CLOCKS_PER_SEC);

	      wsum += (w*pix);
	      printf("%ld\n",w*pix);
	      /***************************************************************/

	      /********** Server Verify the Unit & Weighted SUM *******/
	      //R = r1 + r2... + rn and C=C1 * C2 * ...Cn
	      if ( k == 0 ) {
		element_set(PCOM,pcom);
		mpz_set(R,r);
	      }
	      else {
		element_mul(PCOM,PCOM,pcom);
		mpz_add(R,R,r);
	      }
		
              verify_unit(pairing,ga,hw,unit_enc);
              element_clear(ga); element_clear(hw); element_clear(unit_enc);
	      element_clear(r_enc); mpz_clear(r); element_clear(pcom);
	  }

	  //l^R
          mpz_t smpz; mpz_init(smpz); mpz_set_si (smpz, wsum);
          element_t S_enc; element_init_GT(S_enc,pairing);
          element_pow_mpz(S_enc,l1,smpz);
	
	  //l^S
	  element_t R_enc; element_init_GT(R_enc, pairing);
	  element_pow_mpz(R_enc,l,R);

	  //(l^R) * (l^S)
	  element_t tmp; element_init_GT(tmp, pairing);
  	  element_mul(tmp, S_enc,R_enc); 
	  
          if (!element_cmp(tmp, PCOM)) {
        	printf("unit verifies\n");
     	  }
  	  else {
        	printf("*BUG* signature does not verify *BUG*\n");
  	  }

	  element_clear(S_enc); element_clear(R_enc); mpz_clear(R); element_clear(PCOM);
	  element_clear(tmp); mpz_clear(smpz);

      }
  } 
  
  printf("%f\n",unitvo_cons_time);
  return 0;
  long int pix = 215, w = 12345;

  //generate g^a
  element_t ga;
  generate_Aproof(ga,pairing,pix);
  //printf("The length of proof len = %d\n",pairing_length_in_bytes_compressed_G1(pairing));

  //create h^w
  element_t hw;
  create_Wproof(hw,pairing,w);
  
  //generate l^unit =  e(g^a,h^w)
  element_t unit_enc;
  generate_Uproof(unit_enc,ga,hw,pairing);
  //printf("unit proof size = %d\n", getsizeofGT(pairing));

  long int pix1 = 21, w1 = 1345;

  element_t ga1;
  generate_Aproof(ga1,pairing,pix1);
  element_t hw1;
  create_Wproof(hw1,pairing,w1);

  element_t unit_enc1;
  generate_Uproof(unit_enc1,ga1,hw1,pairing);

  //create l^r
  mpz_t r;
  element_t r_enc;
  create_Rproof(r, r_enc,pairing);
  //element_printf("proof l^r = %B\n", r_enc);

  mpz_t r1;
  element_t r_enc1;
  create_Rproof(r1, r_enc1,pairing);
  //element_printf("proof l^r = %B\n", r_enc1);
   
  //create c=l^r * l^unit
  element_t c, c1;
  generate_Cproof(c,r_enc,unit_enc,pairing);  
  generate_Cproof(c1,r_enc1, unit_enc1 ,pairing);  

  //verification part 1
  //verify_unit(pairing,ga,hw,unit_enc);

  //verification part 2
  mpz_t R; mpz_init(R);
  mpz_add(R,r,r1);
  element_pow_mpz(r_enc,l,R);

  element_t c2;
  generate_Cproof(c2,c,c1,pairing);

  long int s = pix*w + pix1*w1;
  mpz_t smpz;
  mpz_init(smpz);
  mpz_set_si (smpz, s);

  element_t s_enc; element_init_GT(s_enc,pairing);
  element_pow_mpz(s_enc,l1,smpz);

  element_t tmp; element_init_GT(tmp, pairing);
  element_mul(tmp, s_enc,r_enc);
  
  if (!element_cmp(tmp, c2)) {
        printf("unit verifies\n");
     } 
  else {
        printf("*BUG* signature does not verify *BUG*\n");
  } 
 
  element_clear(ga); element_clear(hw); element_clear(g); element_clear(h); element_clear(l);
  element_clear(unit_enc); element_clear(r_enc); mpz_clear(r); 

  pairing_clear(pairing);

  free(input);
  free(fc1_weight);
  return 0;
}

void init_group_generators(pairing_t pairing){

   element_init_G2(g, pairing);
   element_init_GT(l, pairing);
   element_init_GT(l1, pairing);
   element_init_G1(h, pairing);

   element_random(g);
   //element_printf("system parameter g = %B\n", g);

   element_random(l);
   //element_printf("system parameter l = %B\n", l);

   element_random(h);
   //element_printf("system parameter h = %B\n", h);
  
   element_pairing(l1,g,h);
}

unsigned char * compressG1( pairing_t pairing, element_t g1){

    int n = pairing_length_in_bytes_compressed_G1(pairing);
    printf("The length of proof len = %d\n",n);
    unsigned char *data = pbc_malloc(n);

    element_to_bytes_compressed(data, g1);
    return data;
}

unsigned char * compressG2( pairing_t pairing, element_t g2){

    int n = pairing_length_in_bytes_compressed_G2(pairing);
    printf("The length of proof len = %d\n",n);
    unsigned char *data = pbc_malloc(n);

    element_to_bytes_compressed(data, g2);
    return data;
}

int getsizeofGT( pairing_t pairing){

    int n = pairing_length_in_bytes_GT(pairing);
    return n;
}

void generate_Aproof(element_t a_enc, pairing_t pairing, long int a){

    mpz_t ampz;
    mpz_init(ampz);
    element_init_G2(a_enc,pairing);

    mpz_set_si (ampz, a);
    element_pow_mpz(a_enc,g,ampz);
    //element_printf("proof g^a = %B\n", a_enc);
    mpz_clear(ampz);
}

void create_Wproof(element_t w_enc, pairing_t pairing, long int w){

    mpz_t wmpz;

    mpz_init(wmpz);
    mpz_set_si (wmpz, w);
    element_init_G1(w_enc,pairing);
    element_pow_mpz(w_enc,h,wmpz);
    //element_printf("proof h^w = %B\n", w_enc);
    mpz_clear(wmpz);

}

void generate_Uproof(element_t unit_enc, element_t ga, element_t hw, pairing_t pairing){

    element_init_GT(unit_enc, pairing);
    element_pairing(unit_enc,ga,hw);

}

void create_Rproof(mpz_t r, element_t gt, pairing_t pairing){

    gmp_randstate_t state;
    gmp_randinit_default(state);
    mpz_init(r);
    mpz_urandomb (r,state, RANDOMRANGE);

    //clock_t start, end;
    element_init_GT(gt, pairing);
    //start = clock();
    element_pow_mpz(gt,l,r);
    //end = clock();
    //double test = ((double) (end - start)) / CLOCKS_PER_SEC;
    //printf("time=%f",test); 
}

void generate_Cproof(element_t commit, element_t r_enc, element_t unit_enc, pairing_t pairing){


    element_init_GT(commit, pairing);
    element_mul(commit,r_enc ,unit_enc);

}

bool verify_unit(pairing_t pairing, element_t ga, element_t hw, element_t unit_enc){

     element_t tmp1;
     element_init_GT(tmp1, pairing);

     //e(g^a,h^w)
     element_pairing(tmp1, ga, hw);

     //e(g^a,h^w) ?= e(g,h)^(aw)
     bool flag = true;
     if (!element_cmp(tmp1, unit_enc)) {
        printf("unit verifies\n");
     } else {
        printf("*BUG* signature does not verify *BUG*\n");
        flag =  false;
     }

     element_clear(tmp1);
     return flag;
}

void readInputdata( long int  *input, char * filename){

  char * pixstr = malloc( 20 * sizeof(char));
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
			input[count++] = (long int) (NUMSCALE * atof(pixstr));
			//printf("%d\n", input[count-1]);
		}
		i = 0;
	   }
       }
  }
  else printf("file open error\n");
 
  printf("n=%d\n", count);
  free(pixstr);
}

void readWeightParmaters( long int * weight, char * filename){

  char * pixstr = malloc( 20 * sizeof(char));
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
  }
  else printf("file open error\n");

  printf("n=%d\n", count);
  free(pixstr);
}


void UnitVOConstructionTime(pairing_t pairing, long int pix, long int w, 
		element_t ga, element_t hw, element_t unit_enc){

  //generate g^a
  generate_Aproof(ga,pairing,pix);

  //create h^w
  create_Wproof(hw,pairing,w);

  //generate l^unit =  e(g^a,h^w)
  generate_Uproof(unit_enc,ga,hw,pairing);

}

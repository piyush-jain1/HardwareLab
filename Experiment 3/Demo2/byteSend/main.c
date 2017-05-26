

//Read File from file and send to COM port


#include <windows.h>
#include <stdio.h>
#include <time.h>



void delay(int milliseconds)
{
    long pause;
    clock_t now,sincethen;

    pause = milliseconds*(CLOCKS_PER_SEC/1000);
    now = sincethen = clock();
        while( (now-sincethen) < pause )
        now = clock();
}




int main()
{


    int i;                      //count number of bytes sent

    char sendMyByte[1],           //buffer 1 byte data
         fileName[25]=" ",        //File name from which data to be read from
         fileName2[25]=" ",       //File name from which data to be read from
         ch,chh;                  //Temporary byte storage

    FILE *fpRead,*fpWrite;                   //File Pointer


  while(1){

    printf("\nEnter the name of file u wish to send to FPGA\n");
    gets(fileName);

    printf("\nEnter the name of file u want the received files to be saved on ur host computer\n");
    gets(fileName2);



    fpRead = fopen(fileName,"r");    // File read mode
    fpWrite=fopen(fileName2,"w");

    if( fpRead == NULL )
    {
      perror("Error while opening the file.\n");
      exit(EXIT_FAILURE);
    }



     printf("File Opening...... OK \n");

    // Declare variables and structures
    HANDLE hSerial;
    DCB dcbSerialParams = {0};
    COMMTIMEOUTS timeouts = {0};


      printf("Opening serial port...... ");

    // Open available serial port number
      hSerial = CreateFile(
                "\\\\.\\COM4", GENERIC_READ|GENERIC_WRITE, 0, NULL,
                OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );

    if (hSerial == INVALID_HANDLE_VALUE)
    {
            printf("Error\n");
            return 1;
    }
    else
        printf("OK\n");

    // Set device parameters (9600 baud, 1 start bit,
    // 1 stop bit, no parity)


    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (GetCommState(hSerial, &dcbSerialParams) == 0)
    {
        perror("Error getting device state\n");
        CloseHandle(hSerial);
        return 1;
    }

    dcbSerialParams.BaudRate = CBR_9600;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;

    if(SetCommState(hSerial, &dcbSerialParams) == 0)
    {
        perror("Error setting device parameters\n");
        CloseHandle(hSerial);
        return 1;
    }

    // Set COM port timeout settings
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if(SetCommTimeouts(hSerial, &timeouts) == 0)
    {
        perror("Error setting timeouts\n");
        CloseHandle(hSerial);
        return 1;
    }

    // Send specified text (remaining command line arguments)
    DWORD bytes_written,bytes_read;




      printf("Sending bytes to COM Port ...\n");
      i=1;
      while( ( ch = fgetc(fpRead) ) != EOF ) {

           sendMyByte[0]=(int)ch;
            printf("sending..........%c\n",ch);

           if(!WriteFile(hSerial,sendMyByte, 1 , &bytes_written, NULL))
           {
           fprintf(stderr, "Error\n");
           CloseHandle(hSerial);
           return 1;
           }

            ///////////////////////

           printf("Reading Character...");
            ReadFile(hSerial, &chh, 1, &bytes_read, NULL);
            if (bytes_read == 1)
            {
               fputc(chh, fpWrite);
                printf("%c\n", chh);
            }
           delay(1000);
           i++;
      }
       printf("OK\n");

       //closing files
       fclose(fpRead);
       fclose(fpWrite);

      printf("%d bytes written\n", i-1);

    // Close serial port
    printf("Closing serial port...");
    if (CloseHandle(hSerial) == 0)
    {
        printf("Error\n");
        return 1;
    }
    printf("OK\n");
  }
    // exit normally
    return 0;
}

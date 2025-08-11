#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <time.h>
#include <time.h>
#include <time.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <linux/wireless.h>
#define ARP_CACHE       "/proc/net/arp"
#define ARP_BUFFER_LEN  90
#define ARP_DELIM       " "
#define IP_MAX_LENGTH 15
#define IP_MIN_LENGTH 7
#define MAC_LENGTH 17
#define PACKET_LOSS_MESSAGE "round-trip"
#define Success 1
#define Fail 0

char pingcmd[18 + IP_MAX_LENGTH] = "ping -c ";
static int flag = 1;
char triggercmd[] = "srsetmeshsd=0";
char iwpriv_cmd[35]= "srmeshmacdetect=";

struct ip_mac_table {
	char IP[IP_MAX_LENGTH + 1];
	char Mac[MAC_LENGTH + 1];
	struct ip_mac_table *next;
};
void handler(int);
int readLine(int Fd, char *Buffer);
char * getField(char * Line_Arg, int Field);
void AddNode(char *Ip, char *Mac, struct ip_mac_table **current);
int CheckifcurrentMacisRepeat(char * Mac, char *Ip, struct ip_mac_table *repeat_current_for_check, struct ip_mac_table **repeat_current ,struct ip_mac_table *current, struct ip_mac_table **repeat_mac_head);

int SendInBandCMD();

int main(int argc, char *argv[])
{
	time_t t;
	int Fd;
	struct ip_mac_table *head;
	struct ip_mac_table *repeat_mac_head;
	struct ip_mac_table *current = head;
	struct ip_mac_table *repeat_current = repeat_mac_head;
	struct ip_mac_table *repeat_current_for_check = repeat_mac_head;
	struct ip_mac_table *prev = NULL;
	char initpingcmd[20];
	char repeatmac[200];
	char alreadycheckmac[200];
	int Ret = 0;
	char * Line;
	FILE *fp;
	char buffertoread[200];

	if(argc != 3)
	{
		printf("Wrong argument numbert\n");
		exit(1);
	}
	sprintf(pingcmd+strlen(pingcmd),"%s", argv[1]);
	sprintf(pingcmd+strlen(pingcmd), "%s",  " -W ");
	sprintf(pingcmd+strlen(pingcmd), "%s", argv[2]);
	sprintf(pingcmd+strlen(pingcmd),"%s", " ");
	sprintf(initpingcmd, "%s", pingcmd);


	if(-1 == daemon(0, 1))
	{
		printf("daemon error\n");
		exit(1);
	}
	struct sigaction act;


	act.sa_handler = handler;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	if(sigaction(SIGQUIT, &act, NULL))
	{
		printf("sigaction error.\n");
		exit(0);
	}

	while(flag)
	{
		char Buffer[ARP_BUFFER_LEN];
		head = (struct ip_mac_table *) malloc(sizeof(struct ip_mac_table));
		repeat_mac_head = (struct ip_mac_table *) malloc(sizeof(struct ip_mac_table));
		head->next = NULL;
		repeat_mac_head->next = NULL;

		Fd = open(ARP_CACHE , O_RSYNC , 0644);
		if(Fd == -1)
		{
			printf("open error\n");
		}

		/* Ignore first line */
		Ret = readLine(Fd, &Buffer[0]);

		/* Read first Entry */
		Ret = readLine(Fd, &Buffer[0]);
		Line = &Buffer[0];


		if(Ret == 0)
		{
			/* Get First Ip, Mac, Interface */
			char * Ip       = getField(Line, 0);
			char * Mac      = getField(Line, 3);
			strcpy(head->IP,Ip);
			strcpy(head->Mac,Mac);
			free(Ip);
			free(Mac);
		}

		/* Read the second Entry */
		Ret = readLine(Fd, &Buffer[0]);

		current = head;
		repeat_current = repeat_mac_head;

		/* Read arp table line by line*/
		while (Ret == 0)
		{
			/* Get Ip, Mac, Interface */
			char * Ip       = getField(Line, 0);
			char * Mac      = getField(Line, 3);
			/* Build head and repeat_head */
			do{
				if (current->next != NULL)
				{
					if(CheckifcurrentMacisRepeat(Mac, Ip, repeat_current_for_check, &repeat_current , current, &repeat_mac_head))
					{
						repeat_current_for_check = repeat_mac_head;
						break;
					}
					current = current->next;
				}
				if(current->next == NULL)
				{
					if(CheckifcurrentMacisRepeat(Mac, Ip, repeat_current_for_check, &repeat_current , current, &repeat_mac_head))
						repeat_current_for_check = repeat_mac_head;
					else
						AddNode(Ip , Mac, &current);
				}
			}while(current->next);

			current = head;

			Ret = readLine(Fd, &Buffer[0]);
			free(Ip);
			free(Mac);
		}
		current = head;
		repeat_current = repeat_mac_head;



		/* ping the IP in the repeat_mac_head*/
		/* Loop repeat mac table */
		while(repeat_current){
			char *palreadycheck;
			palreadycheck = strstr (alreadycheckmac, repeat_current->Mac);

			/* if haven't check, ping */
			if (palreadycheck == NULL && (strlen(repeat_current->IP) <= IP_MAX_LENGTH) && (strlen(repeat_current->IP) >= IP_MIN_LENGTH))
			{
				sprintf(pingcmd+strlen(pingcmd), "%s",  repeat_current->IP);
				if((fp = popen(pingcmd, "r")) == NULL) {
					perror("Fail to popen\n");
					exit(1);
				}
				while(fgets(buffertoread, 200, fp) != NULL)
				{
					char *pch;
					pch = strstr (buffertoread,PACKET_LOSS_MESSAGE);

					/* If ping Pass */
					if (pch != NULL)
					{
						/* append mac */
						char *prepeatmacch;
						prepeatmacch = strstr (repeatmac, repeat_current->Mac);

						/* Not in the mac list, append to the list*/
						if(prepeatmacch == NULL)
						{
							/* build repeat mac list */
							sprintf(repeatmac+strlen(repeatmac), "%s", repeat_current->Mac);
							sprintf(repeatmac+strlen(repeatmac), "%s", "-");
						} else {
							/* Repeat mac and have not been check */
							sprintf(iwpriv_cmd, "%s", "srmeshmacdetect=");
							sprintf(iwpriv_cmd+strlen(iwpriv_cmd),  "%s", repeat_current->Mac);
							sprintf(alreadycheckmac+strlen(alreadycheckmac), "%s", repeat_current->Mac);

							/* Send srmeshmacdetect */
							if(SendInBandCMD() == Fail)
								perror("Fail to SendInBandcmd\n");


							break;
						}
					}
				}
				sprintf(pingcmd, "%s", initpingcmd);

				repeat_current = repeat_current->next;

				pclose(fp);
			}
			else
			{
				repeat_current = repeat_current->next;
			}
		}

		sprintf(iwpriv_cmd, "%s", "srsetmeshsd=0");
		if(SendInBandCMD() == Fail)
			perror("Fail to SendInBandcmd\n");

		current = head;
		repeat_current = repeat_mac_head;


		close(Fd);

		memset(alreadycheckmac, 0, sizeof(alreadycheckmac));
		memset(repeatmac, 0, sizeof(repeatmac));
		while(current != NULL) {
			prev = current;
			current = current->next;
			free(prev);
		}
		while(repeat_current != NULL) {
			prev = repeat_current;
			repeat_current = repeat_current->next;
			free(prev);
		}

		sleep(1);
	}


	return 0;
}
void handler(int sig)
{
	printf("I got a signal %d\nI'm quitting.\n", sig);
	flag = 0;
}
int readLine(int Fd, char *Buffer) {
    if (Fd < 0)
    {
        return -1;
    }

    char ch;
    size_t Read = 0;

    while (read(Fd, (Buffer + Read), 1))
    {
        ch = Buffer[Read];
        if (ch == '\n')
        {
            break;
        }
        Read++;
    }

    if (Read)
    {
        Buffer[Read] = 0;
        return 0;
    }

    return -1;

}
char * getField(char * Line_Arg, int Field)
{
    char * Line = malloc(strlen(Line_Arg)), *ptr;
    memcpy(Line, Line_Arg, strlen(Line_Arg));
    ptr = Line;

    char * s;
    s = strtok(Line, ARP_DELIM);
    while (Field && s)
    {
        s = strtok(NULL, ARP_DELIM);
        Field--;
    };

    char * ret;
    if (s)
    {
        ret = (char*)malloc(strlen(s) + 1);
        memset(ret, 0, strlen(s) + 1);
        memcpy(ret, s, strlen(s));
    }
    free(ptr);

    return s ? ret : NULL;
}

void AddNode(char *Ip, char *Mac, struct ip_mac_table **current)
{
	(*current)->next = (struct ip_mac_table *) malloc(sizeof(struct ip_mac_table));
	(*current) = (*current)->next;
	strcpy((*current)->IP,Ip);
	strcpy((*current)->Mac,Mac);
	(*current)->next = NULL;
}

int FoundRepeatmacinhead(struct ip_mac_table *repeat_current_for_check, char *Mac)
{
	int found = 0;
	while((repeat_current_for_check)){
		if(strcmp((repeat_current_for_check)->Mac, Mac) == 0)
		{
			found =1;
			break;
		}
		(repeat_current_for_check) = (repeat_current_for_check)->next;
	}
	return found;
}

int CheckifcurrentMacisRepeat(char * Mac, char *Ip, struct ip_mac_table *repeat_current_for_check, struct ip_mac_table **repeat_current ,struct ip_mac_table *current, struct ip_mac_table **repeat_mac_head)
{
	int found = 0;
	if (strcmp(Mac, current->Mac)==0)
	{
		found = 1;
		if(strcmp(Ip,current->IP)!=0)
		{
			if((*repeat_mac_head)->next == NULL)
			{
				strcpy((*repeat_mac_head)->IP, current->IP);
				strcpy((*repeat_mac_head)->Mac, current->Mac);
			}
			else
			{
				if(!FoundRepeatmacinhead(repeat_current_for_check ,current->Mac))
				{
					AddNode (current->IP , current->Mac, &(*repeat_current));
				}
			}
			AddNode (Ip , Mac, &(*repeat_current));
		}
	}

	return found;
}

int GetInterface(char interface[])
{
	FILE *fpread;
	char buffertoread[200];
	int status = Fail;

	if((fpread = popen("ifconfig", "r")) == NULL) {
		perror("Fail to popen\n");
		return Fail;
	}
	while(fgets(buffertoread, 200, fpread) != NULL)
	{
		char *pch;
		pch = strstr (buffertoread, "ra0");
		if (pch != NULL)
		{
			sprintf((interface), "%s", "ra0");
			status = Success;
			break;
		}
		pch = strstr (buffertoread, "rax0");
		if (pch != NULL)
		{
			sprintf((interface), "%s", "rax0");
			status = Success;
			break;
		}
		pch = strstr (buffertoread, "rai0");
		if (pch != NULL)
		{
			sprintf((interface), "%s", "rai0");
			status = Success;
			break;
		}
	}

	pclose(fpread);
	return status;
}

int SendInBandCMD()
{
	/* Send inband cmd */
	int sockfd = 0;
	struct iwreq iwr;
	char interface[5] = "ra0";

	if(GetInterface(interface) == Fail)
		return Fail;

	if((sockfd = socket(AF_INET,SOCK_DGRAM,0))<0)
	{
		perror("Fail to open socket\n");
		return Fail;
	}
	memset(&iwr, 0, sizeof(struct iwreq));
	strcpy(iwr.ifr_ifrn.ifrn_name, interface);

	iwr.u.data.pointer = (void *)iwpriv_cmd;
	iwr.u.data.length = strlen(iwpriv_cmd);

	/*printf("name : %s , cmd : %s , len : %d\n", iwr.ifr_ifrn.ifrn_name, (char *)iwr.u.data.pointer , iwr.u.data.length);*/

	if (ioctl(sockfd, 0x8BE2, &iwr) < 0)
	{
		perror("Unable to clear station statistics");
		return Fail;
	}
	else
	{
		printf("0x8be2 Daemon command success\n");
	}

	close(sockfd);
	return Success;
}

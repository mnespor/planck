#import "PLKCommandLine.h"
#include <getopt.h>
#import "PLKExecutive.h"
#import "PLKScript.h"
#import "PLKLegal.h"

#define PLANCK_VERSION "1.5"

@implementation PLKCommandLine

+(int)processArgsCount:(int)argc vector:(char * const *)argv
{
    int exitValue = EXIT_SUCCESS;
    
    // Documented options
    BOOL help = NO;
    BOOL legal = NO;
    NSMutableArray* scripts = [NSMutableArray new]; // of PLKScript
    NSString* srcPath = @"src";
    NSString* mainNsName = nil;
    BOOL repl = NO;
    BOOL verbose = NO;
    BOOL dumbTerminal = NO;
    
    // Undocumented options, used for development.
    // The defaults set here are for release use.
    NSString* outPath = nil;
    
    int option = -1;
    static struct option longopts[] =
    {
        // Documented options
        {"help", no_argument, NULL, 'h'},
        {"legal", no_argument, NULL, 'l'},
        {"init", optional_argument, NULL, 'i'},
        {"eval", optional_argument, NULL, 'e'},
        {"src", optional_argument, NULL, 's'},
        {"verbose", optional_argument, NULL, 'v'},
        {"dumb-terminal", optional_argument, NULL, 'd'},
        {"main", optional_argument, NULL, 'm'},
        {"repl", optional_argument, NULL, 'r'},
        
        // Undocumented options used for development
        {"out", optional_argument, NULL, 'o'},

        {0, 0, 0, 0}
    };
    
    const char *shortopts = "h?li:e:s:vdm:ro:b";
    while ((option = getopt_long(argc, argv, shortopts, longopts, NULL)) != -1) {
        switch (option) {
            case '?':
            {
                help = YES;
                break;
            }
            case 'h':
            {
                help = YES;
                break;
            }
            case 'l':
            {
                legal = YES;
                break;
            }
            case 'i':
            {
                [scripts addObject:[[PLKScript alloc] initWithPath:[NSString stringWithCString:optarg encoding:NSMacOSRomanStringEncoding]]];
                break;
            }
            case 'e':
            {
                [scripts addObject:[[PLKScript alloc] initWithExpression:[NSString stringWithCString:optarg encoding:NSMacOSRomanStringEncoding]
                                                              printIfNil:NO]];
                break;
            }
            case 's':
            {
                srcPath = [NSString stringWithCString:optarg encoding:NSMacOSRomanStringEncoding];
                break;
            }
            case 'v':
            {
                verbose = YES;
                break;
            }
            case 'd':
            {
                dumbTerminal = YES;
                break;
            }
            case 'm':
            {
                mainNsName = [NSString stringWithCString:optarg encoding:NSMacOSRomanStringEncoding];
                break;
            }
            case 'r':
            {
                repl = YES;
                break;
            }
            case 'o':
            {
                outPath = [NSString stringWithCString:optarg encoding:NSMacOSRomanStringEncoding];
                break;
            }
        }
    }
    argc -= optind;
    argv += optind;
    
    NSMutableArray* args = [[NSMutableArray alloc] init];
    while (argc-- > 0) {
        [args addObject:[NSString stringWithCString:*argv++ encoding:NSUTF8StringEncoding]];
    }
    
    // Argument validation
    
    if (scripts.count == 0 && !mainNsName && args.count==0) {
        repl = YES;
    }
    
    // Process arguments
    
    if (mainNsName && repl) {
        printf("Only one main-opt can be specified.");
    } else {
        if (help) {
            printf("planck %s\n", PLANCK_VERSION);
            printf("Usage:  planck [init-opt*] [main-opt] [args]\n");
            printf("\n");
            printf("  With no options or args, runs an interactive Read-Eval-Print Loop\n");
            printf("\n");
            printf("  init options:\n");
            printf("    -i, --init path     Load a file or resource\n");
            printf("    -e, --eval string   Evaluate expressions in string; print non-nil values\n");
            printf("    -s, --src  path     Use path for source. Default is \"src\"\n");
            printf("    -v, --verbose       Emit verbose diagnostic output.\n");
            printf("    -d, --dumb-terminal Disables line editing / VT100 terminal control.\n");
            printf("\n");
            printf("  main options:\n");
            printf("    -m, --main ns-name  Call the -main function from a namespace with args\n");
            printf("    -r, --repl          Run a repl\n");
            printf("    path                Run a script from a file or resource\n");
            printf("    -                   Run a script from standard input\n");
            printf("    -h, -?, --help      Print this help message and exit\n");
            printf("    -l, --legal         Show legal info (licenses and copyrights)\n");
            printf("\n");
            printf("  operation:\n");
            printf("\n");
            printf("    - Enters the cljs.user namespace\n");
            printf("    - Binds *command-line-args* to a seq of strings containing command line\n");
            printf("      args that appear after any main option\n");
            printf("    - Runs all init options in order\n");
            printf("    - Calls a -main function or runs a repl or script if requested\n");
            printf("\n");
            printf("  The init options may be repeated and mixed freely, but must appear before\n");
            printf("  any main option.\n");
            printf("\n");
            printf("  Paths may be absolute or relative in the filesystem.\n");
            printf("\n");
        } else if (legal) {
            [PLKLegal displayLegalese];
        } else {
            return [[[PLKExecutive alloc] init] runScripts:scripts
                                                   srcPath:srcPath
                                                   verbose:verbose
                                                mainNsName:mainNsName
                                                      repl:repl
                                                   outPath:outPath
                                              dumbTerminal:dumbTerminal
                                                      args:args];
        }
    }
    
    return exitValue;
}

@end

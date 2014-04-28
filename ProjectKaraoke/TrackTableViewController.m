//
//  TrackTableViewController.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-04-22.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "TrackTableViewController.h"
#import "SCUI.h"
#import "RecordViewController.h"
#import "UserManager.h"

@interface TrackTableViewController () <UIAlertViewDelegate>

@end

@implementation TrackTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (IBAction)recordAction:(id)sender {
    if ([SCSoundCloud account]) {
        RecordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"SoundCloud account is required to use our record feature. Would you like to log in?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
    }
}


- (IBAction)logoutAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 0;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            [UserManager logout];
        }
    }
    else if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
                if (SC_CANCELED(error)) {
                    NSLog(@"SoundCloud: Login request is canceled!");
                }
                else if (error) {
                    NSLog(@"SoundCloud: Error: %@", [error localizedDescription]);
                }
                else {
                    NSLog(@"SoundCloud: User is logged in successfully!");
                    RecordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            };
            
            [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
                SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL completionHandler:handler];
                [self.navigationController presentViewController:loginViewController animated:YES completion:nil];
            }];
        }
    }
}


#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

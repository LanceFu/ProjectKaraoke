//
//  TrackTableViewController.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-04-22.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "TrackTableViewController.h"
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
    RecordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)logoutAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [UserManager logout];
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

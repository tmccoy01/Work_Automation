from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pathlib import Path
import os


class WebHelpers(object):
    """
    Class to automatically load and login to certain webpages
    """
    def __init__(self, browser='Chrome', options=None, logger=print):
        self.opts = options
        self.driver = browser
        self.logger = logger

    @property
    def logger(self):
        return self._logger

    @logger.setter
    def logger(self, method):
        self._logger = method

    @logger.deleter
    def logger(self):
        del self._logger

    @property
    def opts(self):
        return self._opts

    @opts.setter
    def opts(self, options=None):
        self._opts = Options()
        for option in options:
            self._opts.add_argument(option)

    @opts.deleter
    def opts(self):
        del self._opts

    @property
    def driver(self):
        return self._driver

    @driver.setter
    def driver(self, browser):
        if browser == 'Chrome':
            chrome_path = Path('resources') / 'chromedriver.exe'
            self._driver = webdriver.Chrome(chrome_path, options=self._opts)
        elif browser == 'Edge':
            self._driver = webdriver.Edge('C://Program Files (x86)//Microsoft//Edge//Application//msedge.exe')
        elif browser == 'Firefox':
            self._driver = webdriver.Firefox(options=self._opts)
        else:
            raise ValueError('Incorrect browser name.\nMust be one of the following: '
                             '"Chrome", "Edge", or "Firefox"...')

    @driver.deleter
    def driver(self):
        del self._driver

    def new_tab(self, numTabs=1, linkList=()):
        if numTabs != len(linkList) and linkList:
            self.logger('Warning! Number of tabs does not match number of links\nOpening blank pages...')
        if linkList:
            for link in linkList:
                self.driver.execute_script(f'window.open("{link}")')
        while len(self._driver.window_handles) != numTabs+1:
            self.driver.execute_script('window.open("https://google.com")')

    def click_element_date(self, date_str):
        """
        Function to click on an element given the date string

        :param date_str: date string in the form MM/DD/YYYY
        :return None: performs an action of clicking
        """
        column_val = self.driver.find_element_by_xpath('//*[@id="ctl00_phL_grid1_row_0"]')
        self._logger(f'Size of the contents in the column stat is : {column_val}')


if __name__ == '__main__':
    test_num = [2]
    for test in test_num:
        if test == 1:
            hoursObj = WebHelpers(options=('start-maximized',
                                           'disable-infobars'))
            hoursObj.load_jamis()
            hoursObj.new_tab(numTabs=3, linkList=('https://www.espn.com', 'https://www.stackoverflow.com'))
        if test == 2:
            hoursObj = WebHelpers(options=('start-maximized',
                                           'disable-infobars'))


# /html/body/form/div[4]/table[1]/tbody/tr[3]/td/div/table[1]/tbody/tr[1]     -->     //*[@id="ctl00_phL_grid1_row_0"]
# /html/body/form/div[4]/table[1]/tbody/tr[3]/td/div/table[1]/tbody/tr[2]     -->     //*[@id="ctl00_phL_grid1_row_1"]